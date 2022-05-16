# terraform-aws-client-vpn-federated
Creates an AWS Client VPN with federated client authentication

[![tflint](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/workflows/tflint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/actions?query=workflow%3Atflint+event%3Apush+branch%3Amaster)
[![tfsec](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/workflows/tfsec/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/actions?query=workflow%3Atfsec+event%3Apush+branch%3Amaster)
[![yamllint](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/workflows/yamllint/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/actions?query=workflow%3Ayamllint+event%3Apush+branch%3Amaster)
[![misspell](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/workflows/misspell/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/actions?query=workflow%3Amisspell+event%3Apush+branch%3Amaster)
[![pre-commit-check](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/workflows/pre-commit-check/badge.svg?branch=master&event=push)](https://github.com/rhythmictech/terraform-aws-client-vpn-federated/actions?query=workflow%3Apre-commit-check+event%3Apush+branch%3Amaster)
<a href="https://twitter.com/intent/follow?screen_name=RhythmicTech"><img src="https://img.shields.io/twitter/follow/RhythmicTech?style=social&logo=twitter" alt="follow on Twitter"></a>

## Example

Here's what using the module will look like
```hcl
module "vpn" {
  source = "rhythmictech/client-vpn-federated/aws"

  name                   = "vpn"
  additional_routes      = var.additional_routes
  associated_subnets     = var.associated_subnets
  client_cidr_block      = var.vpn_client_cidr_block
  saml_metadata_document = file("${path.module}/saml-metadata.xml")
  server_certificate_arn = data.aws_acm_certificate.com_cert.arn
  tags                   = local.tags
  vpc_id                 = var.vpc_id

  authorization_rules = [{
    name                 = "allow-all"
    access_group_id      = null
    authorize_all_groups = true
    description          = "Allow All Groups"
    target_network_cidr  = var.cidr_block
  }]

}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_saml_is_defined"></a> [saml\_is\_defined](#module\_saml\_is\_defined) | rhythmictech/errorcheck/terraform | ~> 1.2 |
| <a name="module_saml_not_defined_twice"></a> [saml\_not\_defined\_twice](#module\_saml\_not\_defined\_twice) | rhythmictech/errorcheck/terraform | ~> 1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_ec2_client_vpn_authorization_rule.rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_ec2_client_vpn_route.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_route) | resource |
| [aws_iam_saml_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_routes"></a> [additional\_routes](#input\_additional\_routes) | A list of additional routes that should be attached to the Client VPN endpoint | <pre>list(object({<br>    destination_cidr_block = string<br>    description            = string<br>    target_vpc_subnet_id   = string<br>  }))</pre> | `[]` | no |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | List of security groups to attach to the client vpn network associations | `list(string)` | `[]` | no |
| <a name="input_associated_subnets"></a> [associated\_subnets](#input\_associated\_subnets) | List of subnets to associate with the VPN endpoint | `list(string)` | n/a | yes |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | List of objects describing the authorization rules for the client vpn | <pre>list(object({<br>    access_group_id      = string<br>    authorize_all_groups = bool<br>    description          = string<br>    target_network_cidr  = string<br>  }))</pre> | n/a | yes |
| <a name="input_client_cidr_block"></a> [client\_cidr\_block](#input\_client\_cidr\_block) | IPv4 CIDR block for client addresses. /22 or greater | `string` | n/a | yes |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | How long to keep VPN logs. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to associate with various resources | `string` | n/a | yes |
| <a name="input_saml_metadata_document"></a> [saml\_metadata\_document](#input\_saml\_metadata\_document) | Optional SAML metadata document. Must include this or `saml_provider_arn` | `string` | `null` | no |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn) | Optional SAML provider ARN. Must include this or `saml_metadata_document` | `string` | `null` | no |
| <a name="input_server_certificate_arn"></a> [server\_certificate\_arn](#input\_server\_certificate\_arn) | ARN of ACM certificate to use with Client VPN | `string` | n/a | yes |
| <a name="input_split_tunnel_enabled"></a> [split\_tunnel\_enabled](#input\_split\_tunnel\_enabled) | Whether to enable split tunneling | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of strings containing tags for AWS resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC to attach VPN to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_dns_name"></a> [vpn\_dns\_name](#output\_vpn\_dns\_name) | DNS name to be used by clients when establishing VPN session |
| <a name="output_vpn_endpoint_security_groups"></a> [vpn\_endpoint\_security\_groups](#output\_vpn\_endpoint\_security\_groups) | VPN endpoint security groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## The Giants Underneath this Module
- [pre-commit.com](pre-commit.com)
- [terraform.io](terraform.io)
- [github.com/tfutils/tfenv](github.com/tfutils/tfenv)
- [github.com/segmentio/terraform-docs](github.com/segmentio/terraform-docs)
