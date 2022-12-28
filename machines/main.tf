module "vultr_machine" {
  source       = "./vultr"
  dyndns_token = var.dyndns_token
}
module "homeserver_machine" {
  source       = "./homeserver"
  dyndns_token = var.dyndns_token
}
