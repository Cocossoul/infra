variable "domain" {}
variable "pihole_subdomain" {}
variable "machine" {}
variable "password" {
  type = string
  sensitive = true
}
variable "gateway" {}