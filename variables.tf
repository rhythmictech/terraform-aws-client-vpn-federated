variable "additional_routes" {
  default     = []
  description = "A list of additional routes that should be attached to the Client VPN endpoint"

  type = list(object({
    destination_cidr_block = string
    description            = string
    target_vpc_subnet_id   = string
  }))
}

variable "additional_security_groups" {
  default     = []
  description = "List of security groups to attach to the client vpn network associations"
  type        = list(string)
}

variable "associated_subnets" {
  description = "List of subnets to associate with the VPN endpoint"
  type        = list(string)
}

variable "authorization_rules" {
  description = "List of objects describing the authorization rules for the client vpn"
  type = list(object({
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
}

variable "client_cidr_block" {
  description = "IPv4 CIDR block for client addresses. /22 or greater"
  type        = string
}

variable "cloudwatch_log_retention_days" {
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
        var.cloudwatch_log_retention_days
      )
    )
  }
}

variable "name" {
  description = "Name to associate with various resources"
  type        = string
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
  version = "~> 1.2"

  assert        = var.saml_metadata_document != null || var.saml_provider_arn != null
  error_message = "Must define a value for either `saml_metadata_document` or `saml_provider_arn`."
}

module "saml_not_defined_twice" {
  source  = "rhythmictech/errorcheck/terraform"
  version = "~> 1.2"

  assert        = ! (var.saml_metadata_document != null && var.saml_provider_arn != null)
  error_message = "Must not define both `saml_metadata_document` and `saml_provider_arn`."
}

variable "server_certificate_arn" {
  description = "ARN of ACM certificate to use with Client VPN"
  type        = string

  validation {
    error_message = "Invalid ACM Certificate ARN."

    condition = (
      var.server_certificate_arn == null ||
      length(regexall(
        "^arn:aws:acm:(?P<region>(?:us(?:-gov)?|ap|ca|cn|eu|sa)-(?:central|(?:north|south)?(?:east|west)?)-\\d):(?P<account_id>\\d{12}):certificate\\/(?P<certificate_id>[[:alnum:]]{8}-(?:[[:alnum:]]{4}-){3}[[:alnum:]]{12})$",
        var.server_certificate_arn
      )) > 0
    )
  }
}

variable "split_tunnel_enabled" {
  default     = true
  description = "Whether to enable split tunneling"
  type        = bool
}

variable "tags" {
  default     = {}
  description = "Map of strings containing tags for AWS resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "ID of VPC to attach VPN to"
  type        = string
}
