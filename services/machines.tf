data "terraform_remote_state" "machines" {
  backend = "s3"

  config = {
    bucket         = "cocopaps-terraform-states"
    key            = "infra/machines.tf"
    region         = "eu-west-3"
    dynamodb_table = "cocopaps-terraform-locks"
    encrypt        = true
  }
}

# -----------------------------------------------------------------------------
locals {
  vultr_machine = {
    dyndns_domain = data.terraform_remote_state.machines.outputs.vultr_dyndns_domain
    name          = "vultr"
  }
}
provider "docker" {
  host     = "ssh://coco@${local.vultr_machine.dyndns_domain}:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "vultr_machine"
}
module "vultr_reverse-proxy" {
  source = "./reverse-proxy"
  providers = {
    docker = docker.vultr_machine
  }
}
module "vultr_netdata" {
  source    = "./netdata"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.vultr_machine
  subdomain = "monitoring.vultr"
  monitoring_admin_password_hash = htpasswd_password.monitoring_admin.bcrypt
  discord_notification_settings = {
    webhook_url = var.discord_webhook_vultr
    channel = "vultr"
  }
  providers = {
    docker = docker.vultr_machine
  }
}
# -----------------------------------------------------------------------------
locals {
  homeserver_machine = {
    dyndns_domain = data.terraform_remote_state.machines.outputs.homeserver_dyndns_domain
    name          = "homeserver"
  }
}
provider "docker" {
  host     = "ssh://coco@${local.homeserver_machine.dyndns_domain}:1844"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "homeserver_machine"
}
module "homeserver_reverse-proxy" {
  source = "./reverse-proxy"
  providers = {
    docker = docker.homeserver_machine
  }
}
module "homeserver_netdata" {
  source    = "./netdata"
  domain    = data.cloudflare_zone.cocopaps
  machine   = local.homeserver_machine
  subdomain = "monitoring.homeserver"
  monitoring_admin_password_hash = htpasswd_password.monitoring_admin.bcrypt
  discord_notification_settings = {
    webhook_url = var.discord_webhook_homeserver
    channel = "homeserver"
  }
  providers = {
    docker = docker.homeserver_machine
  }
}
