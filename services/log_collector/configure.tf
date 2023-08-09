locals {
  fluentconf = templatefile("${path.module}/src/config/fluent.template.conf",
    {
      elasticsearch_host = var.log_aggregator.host
      elasticsearch_port = var.log_aggregator.port
      elasticsearch_scheme = var.log_aggregator.scheme
      elasticsearch_password = var.log_aggregator.password
      machine_name = var.machine.name
    }
  )
}
