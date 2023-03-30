variable "domain" {}
variable "subdomain" {
  type = string
}
variable "machine" {}
variable "entrypoint" {
  default = "secure"
}
