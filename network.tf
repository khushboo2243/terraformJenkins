resource "oci_core_virtual_network" "VCN" {
  cidr_block = "10.0.0.0/16"
  dns_label = "VCN"
  compartment_id = "${var.compartment_ocid}"
  display_name = "Demo_VCN"
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