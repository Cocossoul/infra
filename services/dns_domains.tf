data "cloudflare_zone" "cocopaps" {
  name = "cocopaps.com"
}

data "cloudflare_zone" "tbeteouquoi" {
  name = "tbeteouquoi.fr"
}

locals {
    hostnames = [
      {
        "subdomain" = "@",
        "private" = false,
        "domain" = data.cloudflare_zone.tbeteouquoi
      },
      {
        "subdomain" = "passbolt",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "cloud",
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "gatus",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "monitoring",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "mealie",
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "@",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "home",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "commander",
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "pdf",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "boinc",
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "firefly",
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "fireflyimporter",
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "photos",
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "n8n"
        "private" = false,
        "domain" = data.cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "dns"
        "private" = true,
        "domain" = data.cloudflare_zone.cocopaps
      }
    ]

    hostnames_map = {
        for index, hostname in local.hostnames:
        "${hostname.subdomain}.${hostname.domain.name}" => hostname
    }
}

resource "cloudflare_record" "services" {
  for_each = local.hostnames_map
  zone_id = each.value.domain.zone_id
  name    = each.value.subdomain
  value   = local.vultr_machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
