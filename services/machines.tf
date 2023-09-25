locals {
  vultr_machine = {
    dyndns_address = var.vultr_dyndns_address
    name          = "vultr"
    address = module.vultr_cloudflare_tunnel.tunnel_address
  }
}
provider "docker" {
  host     = "ssh://coco@${local.vultr_machine.dyndns_address}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "vultr_machine"
}
module "vultr_reverse-proxy" {
  source = "./reverse-proxy"
  monitoring_admin_password_hash = htpasswd_password.monitoring_admin.bcrypt
  elasticsearch_password_hash = htpasswd_password.elasticsearch.bcrypt
  boinc_password_hash = htpasswd_password.boinc.bcrypt
  cloudflare_global_api_key = var.cloudflare_global_api_key
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_netdata" {
  source    = "./netdata"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "monitoringvultr"
  discord_notification_settings = {
    webhook_url = var.discord_webhook_vultr
    channel = "vultr"
  }
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_cloudflare_tunnel" {
  source = "./cloudflare_tunnel"
  tunnel_name = "vultr"
  cloudflare_account_id = var.cloudflare_account_id
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_watchtower" {
  source                = "./watchtower"
  docker_password = var.docker_password
  providers = {
    docker = docker.vultr_machine
  }
}
# -----------------------------------------------------------------------------
locals {
  homeserver_machine = {
    dyndns_address = var.homeserver_dyndns_address
    name          = "homeserver"
    address = module.homeserver_cloudflare_tunnel.tunnel_address
  }
}
provider "docker" {
  host     = "ssh://coco@${local.homeserver_machine.dyndns_address}:1844"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "homeserver_machine"
}
module "homeserver_reverse-proxy" {
  source = "./reverse-proxy"
  monitoring_admin_password_hash = htpasswd_password.monitoring_admin.bcrypt
  elasticsearch_password_hash = htpasswd_password.elasticsearch.bcrypt
  boinc_password_hash = htpasswd_password.boinc.bcrypt
  cloudflare_global_api_key = var.cloudflare_global_api_key
  providers = {
    docker = docker.homeserver_machine
  }
}
module "homeserver_netdata" {
  source    = "./netdata"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.homeserver_machine
  subdomain = "monitoringhomeserver"
  discord_notification_settings = {
    webhook_url = var.discord_webhook_homeserver
    channel = "homeserver"
  }
  providers = {
    docker = docker.homeserver_machine
  }
}
module "homeserver_cloudflare_tunnel" {
  source = "./cloudflare_tunnel"
  tunnel_name = "homeserver"
  cloudflare_account_id = var.cloudflare_account_id
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
