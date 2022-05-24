# What's this?

Terraform module to deploy externaldns to different DNS provider.

To add new providers, take config from here: https://github.com/bitnami/charts/blob/master/bitnami/external-dns/values.yaml.

To use this module, define the `dns_config` variable as explained below, then call the module as follows:

```
variable "dns_config" { .... }

module "external-dns" {
  source = "git@github.com:nbycomp/nearbyone-terraform-externaldns.git"
  local_config = var.dns_config
}

```

# Supported externaldns providers

Supported providers (with sample configuration to use):

- aws

```
dns_config = {
  provider = "aws"
  domain_filters = ["example.com", "foo.bar.com"]
  provider_config = {
    "credentials" = {
      "secretKey" = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      "accessKey" = "ZZZZZZZZZZZZZZZZZZZZZZZZ"
    }
    "zoneType" = "public"
    "assumeRoleArn" = "...."
    "roleArn" = "...."
  }
}

actual example:

dns_config = {
  provider = "aws"
  domain_filters = ["nbycomp.com", "foo.bar.com"]
  provider_config = {
    "credentials" = {
      "secretKey" = "dfth2er4tyzd3678GJKwTY+zz331122334455667"
      "accessKey" = "AAAAAAAAAAAAAAAAAA"
    }
    "zoneType" = "public"
  }
}



```

- cloudflare

```
dns_config = {
  provider = "cloudflare"
  domain_filters = ["example.com", "foo.bar.com"]
  provider_config = {
    apiToken = "....."       # `CF_API_TOKEN` to set (optional)
    apiKey = "....."         # `CF_API_KEY` to set (optional)
    secretName = "....."     # name of the secret containing cloudflare_api_token or cloudflare_api_key. This ignores cloudflare.apiToken, and cloudflare.apiKey
    email = "foo@bar.com"    # `CF_API_EMAIL` to set (optional). Needed when using CF_API_KEY
    proxied = false          # enable the proxy feature (DDOS protection, CDN...) (optional)
  }
}

actual example:

dns_config = {
  provider = "cloudflare"
  domain_filters = ["nbycomp.com"]
  provider_config = {
    "apiToken" = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
    "proxied" = false
  }
}


```

- google cloud

```
dns_config = {
  provider = "google"
  domain_filters = ["example.com", "foo.bar.com"]
  provider_config = {
    project = "myproject-123456"   # specify the Google project id (NOT name)
    serviceAccountSecret = "..."   # Specify the existing secret which contains credentials.json (optional)
    serviceAccountSecretKey = "credentials.json"    # when using the Google provider with an existing secret, specify the key name (optional)
    serviceAccountKey = ""         # specify the service account key JSON file directly. In this case a new secret will be created holding this service account (optional)
    zoneVisibility = "public"      # fiter for zones of a specific visibility (private or public)
  }
}

actual example:

dns_config = {
  provider = "google"
  domain_filters = ["nbycomp.com"]
  provider_config = {
    "project" = "myproject-222222"     # this is NOT the name! it's the id
    "serviceAccountKey" = <<-EOT
{
  "type": "service_account",
  "project_id": "myproject-222222",
  "private_key_id": "9123da56fa123555555555555555890bbbbbbcccccccccc",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvXXXXXXXXXXXXXXXXXXXXXXXXXXX....aaaaaaa=\n-----END PRIVATE KEY-----\n",
  "client_email": "dnsupdater@myproject-222222.iam.gserviceaccount.com",
  "client_id": "1111111111111111111111",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/dnsupdater%40myproject-222222.iam.gserviceaccount.com"
}
EOT
    "zoneVisibility" = "public"
  }
}
```

- rfc2136 ("dynamic dns")

```
dns_config = {
  provider = "rfc2136"
  domain_filters = ["example.com", "foo.bar.com"]
  provider_config = {
    host = "10.1.1.1"              # the host running bind (or whatever)
    port = 53                      # the port (optional)
    zone = "example.com"           # specify the zone (required)
    tsigSecret = "..."             # the tsig secret to enable security. (do not specify if `secretName` is provided.) (optional)
    secretName =  ".."             # the existing secret which contains your tsig secret. Disables the usage of `tsigSecret` (optional)
    tsigSecretAlg = hmac-sha256    # the tsig secret to enable security (optional)
    tsigKeyname = externaldns-key  # the tsig keyname to enable security (optional)
    tsigAxfr = true                # enable AFXR to enable security (optional)
  }
}

actual example:

dns_config = {
  provider = "rfc2136"
  domain_filters = ["nbycomp.com"]
  provider_config = {
    host = "10.1.1.1"
    port = 53
    zone = "nbycomp.com"
    tsigSecret = "96Ah/a2g0/nLeFGK+d/0tzQcccf9hCEIy34PoXX2Qg8="
    tsigSecretAlg = "hmac-sha256"
    tsigKeyname = "externaldns-key"
    tsigAxfr = true
  }
}

In bind, enable the following:

key "externaldns-key" {
        algorithm hmac-sha256;
        secret "96Ah/a2g0/nLeFGK+d/0tzQcccf9hCEIy34PoXX2Qg8=";
};

zone "nbycomp.com" {
        allow-transfer { key "externaldns-key"; };
        update-policy { grant "externaldns-key" zonesub ANY; };
}
```
