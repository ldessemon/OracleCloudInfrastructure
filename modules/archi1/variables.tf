# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------


variable "vcn_cidr" {
  description = "CIDR block provided by your network administrator"
}

variable "vcn_display_name" {
  description = "Display name of your VCN"
}

variable "compartment_ocid" {
  description = "The OCID of your compartment"
}

variable "oci_user" {
    description = "The user admin"
}
