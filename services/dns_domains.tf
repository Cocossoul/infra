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
        "domain" = cloudflare_zone.tbeteouquoi
      },
      {
        "subdomain" = "passbolt",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "cloud",
        "private" = true,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "gatus",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "monitoring",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "mealie",
        "private" = true,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "@",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "home",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "commander",
        "private" = true,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "pdf",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "boinc",
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "firefly",
        "private" = true,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "fireflyimporter",
        "private" = true,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "photos",
        "private" = true,
        "domain" = cloudflare_zone.cocopaps
      },
      {
        "subdomain" = "n8n"
        "private" = false,
        "domain" = cloudflare_zone.cocopaps
      },
    ]
}

resource "cloudflare_record" "services" {
  for_each = local.hostnames
  zone_id = each.domain.zone_id
  name    = each.subdomain
  value   = local.vultr_machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
