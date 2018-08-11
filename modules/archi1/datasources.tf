# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
    compartment_id = "${var.tenancy_ocid}"
}

# Gets a list of VNIC attachments on the instance
data "oci_core_vnic_attachments" "NatInstanceVnics" {
    compartment_id = "${var.compartment_ocid}"
    availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
    instance_id = "${oci_core_instance.NatInstance.id}"
}

# Gets the OCID of the first (default) vNIC on the NAT instance
data "oci_core_vnic" "NatInstanceVnic" {
	vnic_id = "${lookup(data.oci_core_vnic_attachments.NatInstanceVnics.vnic_attachments[0],"vnic_id")}"
}

data "oci_core_private_ips" "myPrivateIPs" {
    ip_address = "${data.oci_core_vnic.NatInstanceVnic.private_ip_address}"
    subnet_id = "${oci_core_subnet.vcn1_public_subnet.id}"
    #vnic_id =  "${data.oci_core_vnic.NatInstanceVnic.id}"
}