variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "ssh_public_key" {
   default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGP56kfnzmdyLahAjF3W2mQhxA24Si7E5So8ZvSL5tTdNRiowKhv3wOUIwKW8YsNBFi/S7UZyrpIEC27jK+oFfZlysbOWY4ovZsIQ7GZxTjNrmIq38GvU+qeDY3X2Hlb3vFPvRVHJlGVOO06MQCH4xWADTxrf7DE0OXozz2U8wOt6x6OyrFy6sYrxnBDCaLy5i4z/2gKx2yJXYLb8C2LT2NVwf1mgaxjWVPV6Z6TLBOVFhmzaRnQkl7N1QMQWSdW2NI2kqC0CV0mm3q0ZkiDo7J6njYzMdc5qNZdiSy4ElHOp78f9SfB85gGpnXPjJBYpz/ywUjgjYKvQ9TyggvQdB"
  }

  variable "AD" {
    default = "2"
}

variable "InstanceShape" {
    default = "VM.Standard2.1"
}
#
variable "InstanceImageOCID" {
    type = "map"
    default = {
        // Oracle-provided image "Oracle-Linux-7.4-2018.01.20-0"
        // See https://docs.us-phoenix-1.oraclecloud.com/Content/Resources/Assets/OracleProvidedImageOCIDs.pdf
                    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaacvcy3avanrdb4ida456dgktfhab2phyaikmw75yflugq37eu6oya"
                    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaavzrrzlq2zvj5fd5c27jed7fwou5aqkezxbtmys4aolls54zg7f7q"
                    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaandary2dpwhw42xgv2d3zsbax2hln4wgcrm2tulo3dg67mwkly6aq"
    }
}