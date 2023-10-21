locals {
    hostnames = [
      "tbeteouquoi.fr",
      "passbolt.cocopaps.com",
      "cloud.cocopaps.com",
      "gatus.cocopaps.com",
      "gatus2.cocopaps.com",
      "monitoringhomeserver.cocopaps.com",
      "monitoringvultr.cocopaps.com",
      "mealie.cocopaps.com",
      "cocopaps.com",
      "home.cocopaps.com",
      "commander.cocopaps.com",
      "pdf.cocopaps.com",
      "boinc.cocopaps.com",
      "firefly.cocopaps.com",
      "fireflyimporter.cocopaps.com"
    ]
}

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

module "gatus" {
  source    = "./gatus"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "gatus"
  machine   = local.vultr_machine
  discord_webhook = var.discord_webhook_gatus
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

module "mealie" {
  source    = "./mealie"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "mealie"
  machine   = local.homeserver_machine
  providers = {
    docker = docker.homeserver_machine
  }
}

module "ru19h" {
  source = "git@github.com:Cocossoul/ru19h.git"
  ru19h_token = var.ru19h_token
  providers = {
    docker = docker.vultr_machine
  }
}

module "boinc" {
  source  = "./boinc"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "boinc"
  providers = {
    docker = docker.vultr_machine
  }
}

module "commander" {
  source    = "./commander"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "commander"
  machine   = local.homeserver_machine
  providers = {
    docker = docker.homeserver_machine
  }
}

module "pdf" {
  source  = "./pdf-tools"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "pdf"
  providers = {
    docker = docker.vultr_machine
  }
}

module "gatus_homeserver" {
  source    = "./gatus"
  domain    = data.cloudflare_zone.cocopaps
  subdomain = "gatus2"
  machine   = local.homeserver_machine
  discord_webhook = var.discord_webhook_gatus
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
  providers = {
    docker = docker.homeserver_machine
  }
}
