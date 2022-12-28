resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id

  config {
    ingress_rule {
      hostname = "home.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "home.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "logs.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "logs.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "aggregator.logs.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "aggregator.logs.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "mealie.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "mealie.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "monitoring.vultr.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "monitoring.vultr.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "monitoring.homeserver.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "monitoring.homeserver.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "gatus.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "gatus.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "cloud.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "cloud.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "passbolt.cocopaps.com"
      origin_request {
        http2_origin = true
        origin_server_name = "passbolt.cocopaps.com"
      }
      service  = "https://reverse-proxy:443"
    }
    ingress_rule {
      hostname = "tbeteouquoi.fr"
      origin_request {
        http2_origin = true
        origin_server_name = "tbeteouquoi.fr"
      }
      service  = "https://reverse-proxy:443"
    }

    ingress_rule {
      service  = "http_status:404"
    }
  }
}
