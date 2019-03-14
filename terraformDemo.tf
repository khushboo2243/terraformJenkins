variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}
resource "oci_core_virtual_network" "VCN" {
  cidr_block = "10.0.0.0/16"
  dns_label = "VCN"
  compartment_id = "${var.compartment_ocid}"
  display_name = "NewVCN"
}
resource "oci_core_internet_gateway" "IGW" {
 compartment_id = "${var.compartment_ocid}"
 display_name   = "IGW"
 enabled        = true
 vcn_id         = "${oci_core_virtual_network.VCN.id}"
}

resource "oci_core_route_table" "RouteTable" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "PublicRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.IGW.id}"
  }
  }
  
  resource "oci_core_security_list" "SecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "PublicSubnetSecurityList"

    
    // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
    // allow outbound udp traffic on a port range
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "17"        // udp
    stateless   = true

    udp_options {
      // These values correspond to the destination port range.
      "min" = 319
      "max" = 320
    }
  }
    
    // allow inbound ssh traffic from a specific port
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      source_port_range {
        "min" = 100
        "max" = 100
      }

      // These values correspond to the destination port range.
      "min" = 22
      "max" = 22
    }
  }
    // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = true

    icmp_options {
      "type" = 3
      "code" = 4
    }
  }
    }


//add public subnet

resource "oci_core_subnet" "PublicSubnet" {
  availability_domain        = "LPEH:US-ASHBURN-AD-1"
  cidr_block                 = "10.0.0.0/24"
  compartment_id             = "${var.compartment_ocid}"
  display_name               = "PublicSubnet"
  dns_label                  = "PublicDNS"
  vcn_id                     = "${oci_core_virtual_network.VCN.id}"
  prohibit_public_ip_on_vnic = false
  route_table_id             = "${oci_core_route_table.RouteTable.id}"

  security_list_ids = [
    "${oci_core_security_list.SecurityList.id}",
  ]
}

//adding compute instance to represent web app

resource "oci_core_instance" "Instance" {
  availability_domain = "LPEH:US-ASHBURN-AD-1"
  compartment_id      = "${var.compartment_ocid}"

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    source_type = "image"
  }

  shape = "VM.Standard.E2.1"

  metadata {
    ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGP56kfnzmdyLahAjF3W2mQhxA24Si7E5So8ZvSL5tTdNRiowKhv3wOUIwKW8YsNBFi/S7UZyrpIEC27jK+oFfZlysbOWY4ovZsIQ7GZxTjNrmIq38GvU+qeDY3X2Hlb3vFPvRVHJlGVOO06MQCH4xWADTxrf7DE0OXozz2U8wOt6x6OyrFy6sYrxnBDCaLy5i4z/2gKx2yJXYLb8C2LT2NVwf1mgaxjWVPV6Z6TLBOVFhmzaRnQkl7N1QMQWSdW2NI2kqC0CV0mm3q0ZkiDo7J6njYzMdc5qNZdiSy4ElHOp78f9SfB85gGpnXPjJBYpz/ywUjgjYKvQ9TyggvQdB"
  }

  display_name = "WebAppInstance"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.PublicSubnet.id}"
    assign_public_ip = true
  }
}
