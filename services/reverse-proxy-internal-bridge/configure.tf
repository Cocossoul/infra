resource "local_file" "traefik_dynconfig" {
  content = templatefile("${path.module}/src/config/traefik_dynconfig.template.yml",
    {
        machine = var.destination_machine.name
        domain = var.domain
        ip = var.destination_machine.ip
    }
  )
  file_permission = "0544"
  filename = "${path.module}/src/config/traefik_dynconfig.yml"
}
