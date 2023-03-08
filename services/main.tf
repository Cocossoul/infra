module "youp0m" {
  source                = "./youp0m"
  domain_name           = data.cloudflare_zone.cocopaps.name
  domain_zone_id        = data.cloudflare_zone.cocopaps.zone_id
  machine_name = local.homeserver_machine.name
  machine_dyndns_domain = local.homeserver_machine.dyndns_domain
  subdomain             = "youp0m"
  providers = {
    docker = docker.homeserver_machine
  }
}

module "owncloud" {
  source                  = "./owncloud"
  domain_name             = data.cloudflare_zone.cocopaps.name
  domain_zone_id          = data.cloudflare_zone.cocopaps.zone_id
  subdomain               = "cloud"
  machine_name = local.homeserver_machine.name
  machine_dyndns_domain = local.homeserver_machine.dyndns_domain
  owncloud_admin_username = var.owncloud_admin_username
  owncloud_admin_password = var.owncloud_admin_password
  providers = {
    docker = docker.homeserver_machine
  }
}

module "gatus" {
  source                = "./gatus"
  domain_name           = data.cloudflare_zone.cocopaps.name
  domain_zone_id        = data.cloudflare_zone.cocopaps.zone_id
  subdomain             = "gatus"
  machine_name = local.vultr_machine.name
  machine_dyndns_domain = local.vultr_machine.dyndns_domain
  providers = {
    docker = docker.vultr_machine
  }
}

module "home" {
  source                = "./homer"
  domain_name           = data.cloudflare_zone.cocopaps.name
  domain_zone_id        = data.cloudflare_zone.cocopaps.zone_id
  subdomain             = "home"
  machine_name = local.vultr_machine.name
  machine_dyndns_domain = local.vultr_machine.dyndns_domain
  providers = {
    docker = docker.vultr_machine
  }
}

module "minecraft_server" {
  source                  = "./minecraft_server"
  domain_name             = data.cloudflare_zone.cocopaps.name
  domain_zone_id          = data.cloudflare_zone.cocopaps.zone_id
  subdomain               = "mc"
  machine_name = local.homeserver_machine.name
  machine_dyndns_domain = local.homeserver_machine.dyndns_domain
  providers = {
    docker = docker.homeserver_machine
  }
}