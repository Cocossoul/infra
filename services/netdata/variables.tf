variable "domain" {}
variable "subdomain" {
  type = string
}
variable "machine" {}
variable "discord_notification_settings" {}
variable "monitoring_admin_password_hash" {
  sensitive = true
}
