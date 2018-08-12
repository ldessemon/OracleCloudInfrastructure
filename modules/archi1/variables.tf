# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
   description = "region"
}

variable "tenancy_ocid" {
   description = "Tenant's OCID"
}

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


# Choose an Availability Domain
variable "AD" {
    default = "1"
}



variable "InstanceShape" {
    default = "VM.Standard1.1"
}

variable "InstanceImageOCID" {
  type = "map"
  default = {
    // Oracle-provided image "Oracle-Linux-7.5-2018.07.20-0"
    // See https://docs.cloud.oracle.com/iaas/images/oraclelinux-7x/
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaagqwnrno6c35vplndep6hu5gevyiqqag37muue3ich7g6tbs5aq4q"
  }
}

variable "ssh_public_key" {
    description = "SSH public key"
}

variable "public_instance_name" {}
variable "private_instance_name" {}
variable "dmz_instance_name" {}

