output "vpn_dns_name" {
  description = "DNS name to be used by clients when establishing VPN session"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "vpn_endpoint_security_groups" {
  description = "VPN endpoint security groups"

  value = distinct(
    flatten(
      [for association in aws_ec2_client_vpn_network_association.this : association.security_groups]
    )
  )
}
