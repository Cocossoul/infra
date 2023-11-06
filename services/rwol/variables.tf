variable "domain" {}
variable "subdomain" {
  type = string
}
variable "machine" {}
variable "rwol_password" {
  sensitive = true
}
variable "gamerpc_mac_address" {
  sensitive = true
}
variable "gateway" {}
