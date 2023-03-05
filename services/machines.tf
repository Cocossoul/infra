# -----------------------------------------------------------------------------
locals {
    vultr_machine = {
        dyndns_domain = "cocopapsvultr.duckdns.org"
        name = "vultr"
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
  machine_name = local.vultr_machine.name
}
module "vultr_netdata" {
  source                = "./netdata"
  domain_name           = data.cloudflare_zone.cocopaps.name
  domain_zone_id        = data.cloudflare_zone.cocopaps.zone_id
  machine_dyndns_domain = local.vultr_machine.dyndns_domain
  subdomain             = "monitoring.vultr"
  providers = {
    docker = docker.vultr_machine
  }
  machine_name = local.vultr_machine.name
}
# -----------------------------------------------------------------------------
locals {
    raspipcgamer_machine = {
        dyndns_domain = "cocopapsraspi.duckdns.org"
        name = "raspipcgamer"
    }
}
resource "cloudflare_record" "broker" {
  zone_id = data.cloudflare_zone.cocopaps.name
  name    = "broker"
  value   = local.raspipcgamer_machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}
# -----------------------------------------------------------------------------
