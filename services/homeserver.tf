locals {
  homeserver_machine = {
    dyndns_address = "homeserver.${var.dyndns_zone_name}"
    name           = "homeserver"
    address        = "homeserver.${var.dyndns_zone_name}"
    lan_ip         = "192.168.1.24"
  }
}
provider "docker" {
  host     = "ssh://coco@${local.homeserver_machine.dyndns_address}:1844"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "homeserver_machine"
}
data "docker_registry_image" "homeserver_mariadb" {
  name     = "mariadb:10.11" # renovate_docker
  provider = docker.homeserver_machine
}

resource "docker_image" "homeserver_mariadb" {
  name          = data.docker_registry_image.homeserver_mariadb.name
  pull_triggers = [data.docker_registry_image.homeserver_mariadb.sha256_digest]
  provider      = docker.homeserver_machine
}
module "homeserver_reverse-proxy" {
  source                      = "./reverse-proxy"
  sso_password_hash           = htpasswd_password.sso.bcrypt
  elasticsearch_password_hash = htpasswd_password.elasticsearch.bcrypt
  cloudflare_global_api_key   = var.cloudflare_global_api_key
  cloudflare_account_id       = var.cloudflare_account_id
  crowdsec_api_key            = var.homeserver_crowdsec_api_key
  publish_ports               = true
  providers = {
    docker = docker.homeserver_machine
  }
}
module "homeserver_portainer" {
  source                = "./portainer"
  domain                = data.cloudflare_zone.cocopaps
  subdomain             = "cockpit"
  machine               = local.homeserver_machine
  gateway               = module.homeserver_reverse-proxy.gateway
  hashed_admin_password = htpasswd_password.admin.bcrypt
  providers = {
    docker = docker.homeserver_machine
  }
}

module "homeserver_wireguard" {
  source                 = "./wireguard"
  domain                 = data.cloudflare_zone.cocopaps
  machine                = local.homeserver_machine
  password               = var.admin_password
  pihole_subdomain       = "dns"
  wireguard_ui_subdomain = "wireguard"
  gateway                = module.homeserver_reverse-proxy.gateway
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
    channel     = "homeserver"
  }
  providers = {
    docker = docker.homeserver_machine
  }
}

module "owncloud" {
  source                  = "./owncloud"
  domain                  = data.cloudflare_zone.cocopaps
  subdomain               = "cloud"
  machine                 = local.homeserver_machine
  owncloud_admin_username = "admin_owncloud"
  owncloud_admin_password = var.admin_password
  owncloud_db_password    = var.owncloud_db_password
  mariadb_image           = docker_image.homeserver_mariadb
  gateway                 = module.homeserver_reverse-proxy.gateway
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

module "homeserver_gatus" {
  source          = "./gatus"
  domain          = data.cloudflare_zone.cocopaps
  subdomain       = "gatus"
  machine         = local.homeserver_machine
  config_path     = "homeserver.yml"
  discord_webhook = var.discord_webhook_gatus
  gateway         = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "homeserver_home" {
  source      = "./homer"
  domain      = data.cloudflare_zone.cocopaps
  machine     = local.homeserver_machine
  config_path = "homeserver.yml"
  gateway     = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "firefly" {
  source             = "./firefly"
  domain             = data.cloudflare_zone.cocopaps
  subdomain          = "firefly"
  importer_subdomain = "import.firefly"
  machine            = local.homeserver_machine
  gateway            = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}

module "immich" {
  source    = "./immich"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "photos"
  machine   = local.homeserver_machine
  gateway   = module.homeserver_reverse-proxy.gateway
  providers = {
    docker = docker.homeserver_machine
  }
}
