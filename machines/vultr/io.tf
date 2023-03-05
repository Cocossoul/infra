variable "dyndns_domain" {
  type    = string
  default = "cocopapsvultr"
}

variable "dyndns_token" {
  type = string
}

output "dyndns_domain" {
  value = var.dyndns_domain
}
