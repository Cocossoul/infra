output "vultr_dyndns_domain" {
  value = module.vultr_machine.dyndns_domain
}

output "homeserver_dyndns_domain" {
  value = module.homeserver_machine.dyndns_domain
}
