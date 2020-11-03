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

resource "aws_security_group" "this" {
  name_prefix = var.name
  description = "Client VPN network associations"
  tags        = var.tags
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow self access only by default"
    from_port   = 0
    protocol    = -1
    self        = true
    to_port     = 0
  }

  egress {
    description = "Allow egress by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.associated_subnets) #avoid ordering errors by using a for_each instead of count

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.key

  security_groups = concat(
    [aws_security_group.this.id],
    var.additional_security_groups
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to subnet ID because no matter what I do it always re-orders
      # subnet_id
    ]
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "rules" {
  count = length(var.authorization_rules)

  access_group_id        = var.authorization_rules[count.index].access_group_id
  authorize_all_groups   = var.authorization_rules[count.index].authorize_all_groups
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  description            = var.authorization_rules[count.index].description
  target_network_cidr    = var.authorization_rules[count.index].target_network_cidr

}

resource "aws_ec2_client_vpn_route" "additional" {
  count = length(var.additional_routes)

  description            = try(var.additional_routes[count.index].description, null)
  destination_cidr_block = var.additional_routes[count.index].destination_cidr_block
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_vpc_subnet_id   = var.additional_routes[count.index].target_vpc_subnet_id
}
