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

module "nightly_maintenance" {
  source                = "./nightly_maintenance"
  deploy_workflow_token = var.deploy_workflow_token
  providers = {
    docker = docker.vultr_machine
  }
}

module "log_aggregator" {
  source                = "./log_aggregator"
  domain    = data.cloudflare_zone.cocopaps
  machine = local.vultr_machine
  subdomain_log_viewer = "logs"
  subdomain_log_aggregator = "logaggregator"
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
  source                = "./ru19h"
  ru19h_token = var.ru19h_token
  providers = {
    docker = docker.vultr_machine
  }
}
