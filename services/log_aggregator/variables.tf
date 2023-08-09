variable "domain" {}
variable "subdomain_log_viewer" {}
variable "subdomain_log_aggregator" {}
variable "elasticsearch_password" {
  sensitive = true
}
