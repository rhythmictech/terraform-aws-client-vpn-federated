output "vpn_dns_name" {
  description = "DNS name to be used by clients when establishing VPN session"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "vpn_endpoint_security_groups" {
  description = "VPN endpoint security groups"
  value       = aws_ec2_client_vpn_endpoint.this.security_group_ids
}

output "self_service_saml_provider_arn" {
  description = "ARN of the IAM SAML provider created for the self-service portal (null if not created by this module)"
  value       = try(aws_iam_saml_provider.self_service[0].arn, null)
}
