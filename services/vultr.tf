locals {
  vultr_machine = {
    dyndns_address = "vultr.${var.dyndns_zone_name}"
    name           = "vultr"
    address        = module.vultr_cloudflare_tunnel.tunnel_address
  }
}
provider "docker" {
  host     = "ssh://coco@${local.vultr_machine.dyndns_address}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "vultr_machine"
}
module "vultr_reverse-proxy" {
  source                    = "./reverse-proxy"
  loki_password_hash        = htpasswd_password.loki.bcrypt
  sso_password_hash         = htpasswd_password.sso.bcrypt
  cloudflare_global_api_key = var.cloudflare_global_api_key
  crowdsec_api_key          = var.vultr_crowdsec_api_key
  cloudflare_account_id     = var.cloudflare_account_id
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_netdata" {
  source    = "./netdata"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "monitoring"
  gateway   = module.vultr_reverse-proxy.gateway
  discord_notification_settings = {
    webhook_url = var.discord_webhook_vultr
    channel     = "vultr"
  }
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_cloudflare_tunnel" {
  source                = "./cloudflare_tunnel"
  tunnel_name           = "vultr"
  cloudflare_account_id = var.cloudflare_account_id
  hostnames = [
    for key, hostname in local.hostnames_public_map :
    hostname.subdomain == "@" ? hostname.domain.name : "${hostname.subdomain}.${hostname.domain.name}"
  ]
  gateway = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_fluentd" {
  source  = "./fluentd"
  machine = local.vultr_machine
  gateway = module.vultr_reverse-proxy.gateway
  loki = {
    url      = "https://loki.${data.cloudflare_zone.cocopaps.name}"
    password = random_password.loki.result
  }
  providers = {
    docker = docker.vultr_machine
  }
}

module "loki_grafana" {
  source                 = "./loki_grafana"
  domain                 = data.cloudflare_zone.cocopaps
  machine                = local.vultr_machine
  gateway                = module.vultr_reverse-proxy.gateway
  grafana_admin_password = var.owncloud_admin_password
  subdomain_loki         = "loki"
  subdomain_grafana      = "grafana"
  providers = {
    docker = docker.vultr_machine
  }
}

module "vultr_gatus" {
  source          = "./gatus"
  domain          = data.cloudflare_zone.cocopaps
  subdomain       = "gatus"
  machine         = local.vultr_machine
  config_path     = "vultr.yml"
  discord_webhook = var.discord_webhook_gatus
  gateway         = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}

module "vultr_home" {
  source      = "./homer"
  domain      = data.cloudflare_zone.cocopaps
  machine     = local.vultr_machine
  config_path = "vultr.yml"
  gateway     = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}

module "passbolt" {
  source    = "./passbolt"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "passbolt"
  machine   = local.vultr_machine
  gateway   = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}

module "tbeteouquoi" {
  source  = "./tbeteouquoi"
  domain  = data.cloudflare_zone.tbeteouquoi
  machine = local.vultr_machine
  gateway = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}

module "ru19h" {
  source      = "git@github.com:Cocossoul/ru19h.git"
  ru19h_token = var.ru19h_token
  providers = {
    docker = docker.vultr_machine
  }
}

module "boinc" {
  source    = "./boinc"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "boinc"
  gateway   = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}

module "pdf" {
  source    = "./pdf-tools"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "pdf"
  gateway   = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}

module "n8n" {
  source    = "./n8n"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "n8n"
  machine   = local.vultr_machine
  gateway   = module.vultr_reverse-proxy.gateway
  providers = {
    docker = docker.vultr_machine
  }
}
