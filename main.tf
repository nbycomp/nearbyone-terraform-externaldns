terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
  }
}

# helm config comes from the caller

resource "helm_release" "external-dns" {

  name       = "external-dns"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  values = [

    templatefile("${path.module}/templates/general.yaml", {
      provider = local.config["provider"]
      txt_prefix = local.config["txt_prefix"]
      service_account = local.config["service_account"]
      domain_filters = local.config["domain_filters"]
      sources = local.config["sources"]
    }),

    yamlencode({ "${local.config["provider"]}" = local.config["provider_config"]})
  ]
}
