module "vultr_machine" {
  source       = "./vultr"
  dyndns_token = var.dyndns_token
}
module "raspipcgamer_machine" {
  source              = "./raspipcgamer"
  dyndns_token        = var.dyndns_token
  mosquitto_user      = var.mosquitto_user
  mosquitto_password  = var.mosquitto_password
  gamerpc_mac_address = var.gamerpc_mac_address
}
module "homeserver_machine" {
  source       = "./homeserver"
  dyndns_token = var.dyndns_token
}
