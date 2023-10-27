locals {
  homeserver_machine = {
    dyndns_address = var.homeserver_dyndns_address
    name           = "homeserver"
    address        = var.homeserver_dyndns_address
  }
}
provider "docker" {
  host     = "ssh://coco@${local.homeserver_machine.dyndns_address}:1844"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "homeserver_machine"
}
module "homeserver_reverse-proxy" {
  source = "./reverse-proxy"
  sso_password_hash = htpasswd_password.sso.bcrypt
  elasticsearch_password_hash = htpasswd_password.elasticsearch.bcrypt
  cloudflare_global_api_key = var.cloudflare_global_api_key
  cloudflare_account_id = var.cloudflare_account_id
  crowdsec_api_key = var.homeserver_crowdsec_api_key
  publish_ports = true
  providers = {
    docker = docker.homeserver_machine
  }
}
module "homeserver_netdata" {
  source    = "./netdata"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.homeserver_machine
  subdomain = "monitoring"
  gateway   = module.homeserver_reverse-proxy.gateway
  discord_notification_settings = {
    webhook_url = var.discord_webhook_homeserver
    channel = "homeserver"
  }
  providers = {
    docker = docker.homeserver_machine
  }
}
module "homeserver_watchtower" {
  source                = "./watchtower"
  docker_password = var.docker_password
  providers = {
    docker = docker.homeserver_machine
  }
}

module "owncloud" {
  source                  = "./owncloud"
  domain                  = data.cloudflare_zone.cocopaps
  subdomain               = "cloud"
  machine                 = local.homeserver_machine
  owncloud_admin_username = var.owncloud_admin_username
  owncloud_admin_password = var.owncloud_admin_password
  owncloud_db_password = var.owncloud_db_password
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "mealie" {
  source    = "./mealie"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "mealie"
  machine   = local.homeserver_machine
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "commander" {
  source    = "./commander"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "commander"
  machine   = local.homeserver_machine
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "gatus_homeserver" {
  source    = "./gatus"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "gatus2"
  machine   = local.homeserver_machine
  discord_webhook = var.discord_webhook_gatus
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "firefly" {
  source                  = "./firefly"
  domain                  = data.cloudflare_zone.cocopaps
  subdomain               = "firefly"
  importer_subdomain      = "fireflyimporter"
  machine                 = local.homeserver_machine
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "immich" {
  source                  = "./immich"
  domain                  = data.cloudflare_zone.cocopaps
  subdomain               = "photos"
  machine                 = local.homeserver_machine
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}