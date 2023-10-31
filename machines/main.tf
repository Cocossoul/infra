module "vultr_machine" {
  source       = "./vultr"
  dyndns_token = var.dyndns_token
  dyndns_address = var.vultr_dyndns_address
}
module "homeserver_machine" {
  source       = "./homeserver"
  dyndns_token = var.dyndns_token
  dyndns_address = "homeserver.${var.dyndns_domain}"
}
