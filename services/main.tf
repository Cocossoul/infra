module "owncloud" {
  source                  = "./owncloud"
  domain                  = data.cloudflare_zone.cocopaps
  subdomain               = "cloud"
  machine                 = local.homeserver_machine
  owncloud_admin_username = var.owncloud_admin_username
  owncloud_admin_password = var.owncloud_admin_password
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

module "vault" {
  source                  = "./vault"
  domain             = data.cloudflare_zone.cocopaps
  subdomain               = "vault"
  machine            = local.vultr_machine
  providers = {
    docker = docker.homeserver_machine
  }
}

# module "minecraft_server" {
#   source                = "./minecraft_server"
#   domain           = data.cloudflare_zone.cocopaps
#   subdomain             = "mc"
#   machine          = local.homeserver_machine
#   providers = {
#     docker = docker.homeserver_machine
#   }
# }
