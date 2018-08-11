output "vcn_id" {
  value = "${oci_core_vcn.vcn1.id}"
}

output "user_auth_token" {
    value = "${oci_identity_auth_token.auth-token1.token}"
}