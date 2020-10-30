variable "name" {
  description = "Name to associate with various resources"
  type        = string
}

variable "log_retention_days" {
  default     = 30
  description = "How long to keep VPN logs. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number

  validation {
    error_message = "Invalid value. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."

    condition = (
      contains(
        [
          1,
          3,
          5,
          7,
          14,
          30,
          60,
          90,
          120,
          150,
          180,
          365,
          400,
          545,
          731,
          1827,
          3653,
          0
        ],
        var.log_retention_days
      )
    )
  }
}

variable "tags" {
  default     = {}
  description = "Map of strings containing tags for AWS resources"
  type        = map(string)
}

variable "saml_metadata_document" {
  default     = null
  description = "Optional SAML metadata document. Must include this or `saml_provider_arn`"
  type        = string
}

variable "saml_provider_arn" {
  default     = null
  description = "Optional SAML provider ARN. Must include this or `saml_metadata_document`"
  type        = string

  validation {
    error_message = "Invalid SAML provider ARN."

    condition = (
      var.saml_provider_arn == null ||
      try(length(regexall(
        "^arn:aws:iam::(?P<account_id>\\d{12}):saml-provider/(?P<provider_name>[\\w+=,\\.@-]+)$",
        var.saml_provider_arn
        )) > 0,
        false
    ))
  }
}

module "saml_is_defined" {
  source  = "rhythmictech/errorcheck/terraform"
  version = "~> 1.0"

  assert        = var.saml_metadata_document != null || var.saml_provider_arn != null
  error_message = "Must define a value for either `saml_metadata_document` or `saml_provider_arn`."
}

module "saml_not_defined_twice" {
  source  = "rhythmictech/errorcheck/terraform"
  version = "~> 1.0"

  assert        = ! (var.saml_metadata_document != null && var.saml_provider_arn != null)
  error_message = "Must not define both `saml_metadata_document` and `saml_provider_arn`."
}

variable "client_cidr_block" {
  type        = string
  description = "(optional) describe your variable"
}

variable "server_certificate_arn" {
  description = "ARN of ACM certificate to use with Client VPN"
  type        = string

  validation {
    error_message = "Invalid ACM Certificate ARN."

    condition = (
      var.server_certificate_arn == null ||
      length(regexall(
        "^arn:aws:acm:(?P<region>^(?:us(?:-gov)?|ap|ca|cn|eu|sa)-(?:central|(?:north|south)?(?:east|west)?)-\\d$):(?P<account_id>\\d{12}):saml-provider/(?P<provider_name>[\\w+=,\\.@-]+)$",
        var.server_certificate_arn
      )) > 0
    )
  }
}

variable "split_tunnel_enabled" {
  default     = true
  description = "Whether to enable split tunnelling"
  type        = bool
}

variable "network_association_security_groups" {
  default     = null
  description = "List of security groups to attach to the client vpn network associations"
  type        = list(string)
}

variable "additional_routes" {
  default     = []
  description = "A list of additional routes that should be attached to the Client VPN endpoint"

  type = list(object({
    destination_cidr_block = string
    description            = string
    target_vpc_subnet_id   = string
  }))
}

variable "associated_subnets" {
  type        = list(string)
  description = "List of subnets to associate with the VPN endpoint"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC to attach VPN to"
}
