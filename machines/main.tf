module "vultr_machine" {
  source       = "./vultr"
  dyndns_token = var.dyndns_token
}
module "raspipcgamer_machine" {
  source       = "./raspipcgamer"
  dyndns_token = var.dyndns_token
}
