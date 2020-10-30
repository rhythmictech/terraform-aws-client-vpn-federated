locals {
  tags = merge(
    var.tags,
    {
      terraform_module = basename(abspath(path.module))
    }
  )
}

resource "aws_cloudwatch_log_group" "vpn" {
  name_prefix       = "vpn-${var.name}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "vpn-${var.name}"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}

resource "aws_iam_saml_provider" "this" {
  count = var.saml_metadata_document != null ? 1 : 0

  name                   = var.name
  saml_metadata_document = var.saml_metadata_document
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "Client VPN"
  client_cidr_block      = var.client_cidr_block
  server_certificate_arn = var.server_certificate_arn
  split_tunnel           = var.split_tunnel_enabled
  tags                   = local.tags

  authentication_options {
    type              = "federated-authentication"
    saml_provider_arn = try(aws_iam_saml_provider.this[0].arn, var.saml_provider_arn)
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = zipmap(var.associated_subnets, var.associated_subnets) #avoid ordering errors by using a for_each instead of count

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  security_groups        = var.network_association_security_groups
  subnet_id              = each.key

  lifecycle {
    ignore_changes = [
      # Ignore changes to subnet ID because no matter what I do it always re-orders
      # subnet_id
    ]
  }
}
