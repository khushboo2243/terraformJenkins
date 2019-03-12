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
  display_name   = "RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.IGW.id}"
  }
  }
  
  resource "oci_core_security_list" "SecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.VCN.id}"
  display_name   = "SecurityList"

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
    }
  
