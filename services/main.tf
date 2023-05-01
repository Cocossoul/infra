module "owncloud" {
  source                  = "./owncloud"
  domain                  = data.cloudflare_zone.cocopaps
  subdomain               = "cloud"
  machine                 = local.homeserver_machine
  owncloud_admin_username = var.owncloud_admin_username
  owncloud_admin_password = var.owncloud_admin_password
  owncloud_db_password = var.owncloud_db_password
  providers = {
    docker = docker.homeserver_machine
  }
}

module "rwol" {
  source    = "./rwol"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "rwol"
  machine   = local.homeserver_machine
  gamerpc_mac_address = var.gamerpc_mac_address
  gamerpc_ip_address = var.gamerpc_ip_address
  rwol_password = var.rwol_password
  providers = {
    docker = docker.homeserver_machine
  }
}

module "gatus" {
  source    = "./gatus"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "gatus"
  machine   = local.vultr_machine
  providers = {
    docker = docker.vultr_machine
  }
}

module "home" {
  source  = "./homer"
  domain  = data.cloudflare_zone.cocopaps
  machine = local.vultr_machine
  providers = {
    docker = docker.vultr_machine
  }
}

module "minecraft_server" {
  source                = "./minecraft_server"
  domain           = data.cloudflare_zone.cocopaps
  subdomain             = "mc"
  machine          = local.homeserver_machine
  rcon_password = var.rcon_password
  providers = {
    docker = docker.homeserver_machine
  }
}

module "passbolt" {
  source                = "./passbolt"
  domain           = data.cloudflare_zone.cocopaps
  subdomain             = "passbolt"
  machine          = local.vultr_machine
  providers = {
    docker = docker.vultr_machine
  }
}

module "tbeteouquoi" {
  source                = "./tbeteouquoi"
  domain           = data.cloudflare_zone.tbeteouquoi
  machine          = local.vultr_machine
  providers = {
    docker = docker.vultr_machine
  }
}

module "portfolio" {
  source    = "./portfolio"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "portfolio"
  machine   = local.vultr_machine
  providers = {
    docker = docker.vultr_machine
  }
}
