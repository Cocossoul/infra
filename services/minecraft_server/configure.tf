locals {
  serverproperties = templatefile("${path.module}/src/config/server.template.properties",
    {
      rcon_password = var.rcon_password
    }
  )
}
