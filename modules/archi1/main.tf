# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.8 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.9.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VCN
# ---------------------------------------------------------------------------------------------------------------------

resource "oci_identity_user" "user1" {
  name = "${var.oci_user}"
  description = "user created by terraform"
}

resource "oci_identity_auth_token" "auth-token1" {
  #Required
  user_id = "${oci_identity_user.user1.id}"
  description = "user auth token created by terraform"
}


# ------- VCN -------
resource "oci_core_vcn" "vcn1" {
  cidr_block = "${var.vcn_cidr}"
  dns_label = "vcn1"
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.vcn_display_name}"
}

# ------- DRG -------
resource "oci_core_drg" "vcn1_drg" {
	#Required
	compartment_id = "${var.compartment_ocid}"
}

resource "oci_core_drg_attachment" "vcn1_drg_attachment" {
	#Required
	drg_id = "${oci_core_drg.vcn1_drg.id}"
	vcn_id = "${oci_core_vcn.vcn1.id}"
}

# ------- Internet Gateway -------

resource "oci_core_internet_gateway" "vcn1_internet_gateway" {
	#Required
	compartment_id = "${var.compartment_ocid}"
	enabled = "true"
	vcn_id = "${oci_core_vcn.vcn1.id}"
	display_name = "Internet Gateway"
}

# ================== ROUTE TABLES =================
# ------- Public Route Table -------

resource "oci_core_route_table" "vcn1_public_route_table" {
	#Required
	compartment_id = "${var.compartment_ocid}"
    display_name = "Public Route Table"
      route_rules {
        cidr_block = "0.0.0.0/0"
        network_entity_id = "${oci_core_internet_gateway.vcn1_internet_gateway.id}"
      }
	vcn_id = "${oci_core_vcn.vcn1.id}"
}

# ------- Private Route Table -------

resource "oci_core_route_table" "vcn1_private_route_table" {
	#Required
    display_name = "Private Route Table"    
	compartment_id = "${var.compartment_ocid}"
      route_rules {
        cidr_block = "0.0.0.0/0"
        network_entity_id = "${oci_core_drg.vcn1_drg.id}"
      }
	vcn_id = "${oci_core_vcn.vcn1.id}"
}

# ------- Dmz Route Table -------

resource "oci_core_route_table" "vcn1_dmz_route_table" {
	#Required
    display_name = "DMZ Route Table"    
	compartment_id = "${var.compartment_ocid}"
      route_rules {
        cidr_block = "0.0.0.0/0"
        network_entity_id = "${oci_core_internet_gateway.vcn1_internet_gateway.id}"
      }
	vcn_id = "${oci_core_vcn.vcn1.id}"
}


# ================== SECURITY LIST =================
# ------- Public Security List -------

resource "oci_core_security_list" "vcn1_public_seclist" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Public Sec List"
    vcn_id = "${oci_core_vcn.vcn1.id}"
    egress_security_rules = [{
        destination = "0.0.0.0/0"
        protocol = "6"
    }]
    ingress_security_rules = []
}

resource "oci_core_security_list" "vcn1_private_seclist" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Private Sec List"
    vcn_id = "${oci_core_vcn.vcn1.id}"
    egress_security_rules = [{
        destination = "0.0.0.0/0"
        protocol = "6"
    }]
    ingress_security_rules = []
}

resource "oci_core_security_list" "vcn1_dmz_seclist" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "DMZ Sec List"
    vcn_id = "${oci_core_vcn.vcn1.id}"
    egress_security_rules = [{
        destination = "0.0.0.0/0"
        protocol = "6"
    }]
    ingress_security_rules = []
}

# ================== SECURITY LIST =================
# ------- Public Subnet -------
resource "oci_core_subnet" "vcn1_public_subnet" {
	#Required
    display_name = "Public Subnet"
	availability_domain = "${var.public_subnet_availability_domain}"
	cidr_block = "${var.public_subnet_cidr_block}"
	compartment_id = "${var.compartment_ocid}"
	security_list_ids = ["${oci_core_security_list.vcn1_public_seclist.id}"]
	vcn_id = "${oci_core_vcn.vcn1.id}"
	route_table_id = "${oci_core_route_table.vcn1_public_route_table.id}"
}

resource "oci_core_subnet" "vcn1_private_subnet" {
	#Required
    display_name = "Private Subnet"
	availability_domain = "${var.private_subnet_availability_domain}"
	cidr_block = "${var.private_subnet_cidr_block}"
	compartment_id = "${var.compartment_ocid}"
	security_list_ids = ["${oci_core_security_list.vcn1_private_seclist.id}"]
	vcn_id = "${oci_core_vcn.vcn1.id}"
	route_table_id = "${oci_core_route_table.vcn1_private_route_table.id}"
}
resource "oci_core_subnet" "vcn1_dmz_subnet" {
	#Required
    display_name = "DMZ Subnet"
	availability_domain = "${var.dmz_subnet_availability_domain}"
	cidr_block = "${var.dmz_subnet_cidr_block}"
	compartment_id = "${var.compartment_ocid}"
	security_list_ids = ["${oci_core_security_list.vcn1_dmz_seclist.id}"]
	vcn_id = "${oci_core_vcn.vcn1.id}"
	route_table_id = "${oci_core_route_table.vcn1_dmz_route_table.id}"
}

