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



resource "oci_core_vcn" "vcn1" {
  cidr_block = "${var.vcn_cidr}"
  dns_label = "vcn1"
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.vcn_display_name}"
}

resource "oci_core_internet_gateway" "vcn1_internet_gateway" {
	#Required
	compartment_id = "${var.compartment_ocid}"
	enabled = "true"
	vcn_id = "${oci_core_vcn.vcn1.id}"
	display_name = "${var.internet_gateway_display_name}"
}

resource "oci_core_route_table" "vcn1_private_route_table" {
	#Required
	compartment_id = "${var.compartment_ocid}"
	route_rules {
		#Required
		network_entity_id = "${oci_core_internet_gateway.ws4_internet_gateway.id}"

		#Optional
		cidr_block = "${var.route_table_route_rules_cidr_block}"
		destination = "${var.route_table_route_rules_destination}"
		destination_type = "${var.route_table_route_rules_destination_type}"
	}
	vcn_id = "${oci_core_vcn.ws4_vcn.id}"

	#Optional
	defined_tags = {"Operations.CostCenter"= "42"}
	display_name = "${var.route_table_display_name}"
	freeform_tags = {"Workstream"= "WS4"}
}

# Private Subnet Security List
resource "oci_core_security_list" "${var.env}_${var.private_subnet}_seclist" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_vcn.ExampleVCN.id}"
  display_name = "TFExampleSecurityList"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }

  // allow outbound udp traffic on a port range
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "17" // udp
    stateless = true

    udp_options {
      // These values correspond to the destination port range.
      "min" = 319
      "max" = 320
    }
  }

  // allow inbound ssh traffic from a specific port
  ingress_security_rules {
    protocol = "6" // tcp
    source = "0.0.0.0/0"
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