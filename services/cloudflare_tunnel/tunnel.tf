resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = random_id.tunnel_secret.b64_std
}

locals {
    hostnames = [
      "tbeteouquoi.fr",
      "passbolt.cocopaps.com",
      "cloud.cocopaps.com",
      "gatus.cocopaps.com",
      "monitoringhomeserver.cocopaps.com",
      "monitoringvultr.cocopaps.com",
      "mealie.cocopaps.com",
      "cocopaps.com",
      "home.cocopaps.com",
      "commander.cocopaps.com",
      "boinc.cocopaps.com"
    ]
}

resource "cloudflare_tunnel_config" "config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id

  config {
    dynamic "ingress_rule" {
      for_each = local.hostnames
      content {
        hostname = ingress_rule.value
        origin_request {
          http2_origin = true
          origin_server_name = ingress_rule.value
        }
        service  = "https://reverse-proxy:443"
      }
    }

    ingress_rule {
      service  = "http_status:404"
    }
  }
}
