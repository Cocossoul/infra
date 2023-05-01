variable "cloudflare_token" {
  type = string
  sensitve = true
}
variable "owncloud_admin_username" {
  type = string
  sensitve = true
}
variable "owncloud_admin_password" {
  type = string
  sensitve = true
}
variable "owncloud_db_password" {
  sensitve = true
}
variable "rcon_password" {
  type = string
  sensitve = true
}
variable "gamerpc_mac_address" {
  sensitve = true
}
variable "gamerpc_ip_address" {
  sensitive = true
}
variable "rwol_password" {
  sensitve = true
}
variable "discord_webhook_homeserver" {
  sensitve = true
}
variable "discord_webhook_vultr" {
  sensitve = true
}
