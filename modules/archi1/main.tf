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
    ingress_security_rules = [
    {
        tcp_options {
            "max" = 443
            "min" = 443
        }
        protocol = "6"
        source = "0.0.0.0/0"
    },
	{
        protocol = "all"
        source = "${var.vcn_cidr}"
    },
    {
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            "min" = 22
            "max" = 22
        }
    },
    {
        protocol = "1"
        source = "0.0.0.0/0"
        icmp_options {
            "type" = 3
            "code" = 4
        }
    }]
}

resource "oci_core_security_list" "vcn1_private_seclist" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "Private Sec List"
    vcn_id = "${oci_core_vcn.vcn1.id}"
    egress_security_rules = [{
        destination = "0.0.0.0/0"
        protocol = "6"
    }]
    ingress_security_rules = [
	{
        protocol = "all"
        source = "${var.vcn_cidr}"
    }]
}

resource "oci_core_security_list" "vcn1_dmz_seclist" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "DMZ Sec List"
    vcn_id = "${oci_core_vcn.vcn1.id}"
    egress_security_rules = [{
        protocol = "all"
        destination = "0.0.0.0/0"
    }]

    ingress_security_rules = [
    {
        tcp_options {
            "max" = 443
            "min" = 443
        }
        protocol = "6"
        source = "0.0.0.0/0"
    },
	{
        protocol = "all"
        source = "${var.vcn_cidr}"
    },
    {
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            "min" = 22
            "max" = 22
        }
    },
    {
        protocol = "1"
        source = "0.0.0.0/0"
        icmp_options {
            "type" = 3
            "code" = 4
        }
    }]
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

# =========== Create the NAT vm instance in the Public Subnet ===============

resource "oci_core_instance" "NatInstance" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
    compartment_id = "${var.compartment_ocid}"
    display_name = "nat_instance"
    source_details {
	    #Required
	    source_type = "image"
	    source_id = "${var.InstanceImageOCID[var.region]}"
	}
    shape = "${var.InstanceShape}"
    subnet_id = "${oci_core_subnet.vcn1_public_subnet.id}"
    hostname_label = "natinstance"
    create_vnic_details {
        subnet_id = "${oci_core_subnet.vcn1_public_subnet.id}"
        skip_source_dest_check = true
    }
    metadata {
      ssh_authorized_keys = "${var.ssh_public_key}"
      user_data = "${base64encode(file("${path.module}/user_data.tpl"))}"
    }
    timeouts {
        create = "10m"
    }
}




resource "oci_core_instance" "PrivateInstance" {
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
    compartment_id = "${var.compartment_ocid}"
    display_name = "PrivateInstance"
    source_details {
	    #Required
	    source_type = "image"
	    source_id = "${var.InstanceImageOCID[var.region]}"
	}
    shape = "${var.InstanceShape}"
    create_vnic_details {
      subnet_id = "${oci_core_subnet.vcn1_private_subnet.id}"
      assign_public_ip = false
    }
    metadata {
      ssh_authorized_keys = "${var.ssh_public_key}"
    }
    timeouts {
      create = "10m"
    }
}