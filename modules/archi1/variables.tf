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


variable "public_subnet_cidr_block" {
    description = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
    description = "10.0.2.0/24"
}

variable "dmz_subnet_cidr_block" {
    description = "10.0.3.0/24"
}



variable "public_subnet_availability_domain" {
    description = "KkUJ:US-ASHBURN-AD-1"
}

variable "private_subnet_availability_domain" {
    description = "KkUJ:US-ASHBURN-AD-1"
}

variable "dmz_subnet_availability_domain" {
    description = "KkUJ:US-ASHBURN-AD-1"
}


