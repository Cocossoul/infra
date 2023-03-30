resource "local_file" "server_properties" {
  content = templatefile("${path.module}/src/config/server.template.properties",
    {
      rcon_password = var.rcon_password
    }
  )
  file_permission = "0544"
  filename = "${path.module}/src/config/server.properties"
}
