//adding compute instance to represent web app

resource "oci_core_instance" "Instance" {
  availability_domain = "LPEH:US-ASHBURN-AD-1"
  compartment_id      = "${var.compartment_ocid}"
    shape = "${var.InstanceShape}"
    
    source_details
    {
        source_id   = "${var.InstanceImageOCID[var.region]}"
    
    }


  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }

  display_name = "Web-App-Instance"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.PublicSubnet.id}"
    assign_public_ip = true
  }

}