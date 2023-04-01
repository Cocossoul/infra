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
  providers = {
    docker = docker.vultr_machine
  }
}
# -----------------------------------------------------------------------------
locals {
  raspipcgamer_machine = {
    dyndns_domain = data.terraform_remote_state.machines.outputs.raspipcgamer_dyndns_domain
    name          = "raspipcgamer"
  }
}
resource "cloudflare_record" "broker" {
  zone_id = data.cloudflare_zone.cocopaps.zone_id
  name    = "broker"
  value   = local.raspipcgamer_machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}
provider "docker" {
  host     = "ssh://pi@${local.raspipcgamer_machine.dyndns_domain}:1882"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
  alias    = "raspipcgamer_machine"
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
  providers = {
    docker = docker.homeserver_machine
  }
}
# -----------------------------------------------------------------------------
