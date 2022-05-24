variable "config_defaults" {
  type = object({
    provider = string,
    txt_prefix = string,
    service_account = string,
    domain_filters = list(string),
    sources = list(string),
    provider_config = map(string)
  })
  default = {
    "provider" = ""
    "txt_prefix" = "external-dns-"
    "service_account" = "external-dns"
    "domain_filters" = []
    "sources" = ["service", "ingress"]
    "provider_config" = {}
  }
}

variable "local_config" {}

locals {
  config = merge(
    var.config_defaults, 
    var.local_config 
  )
}
