resource "docker_container" "passbolt_db" {
  image = var.mariadb_image.image_id
  name  = "passbolt_db"

  env = [
    "MYSQL_RANDOM_ROOT_PASSWORD=\"true\"",
    "MYSQL_DATABASE=passbolt",
    "MYSQL_USER=passbolt",
    "MYSQL_PASSWORD=${random_password.passbolt_db_password.result}"
  ]
  volumes {
    container_path = "/var/lib/mysql"
    volume_name    = docker_volume.passbolt_db.name
  }
  networks_advanced {
    name = var.gateway
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "passbolt_db" {
  name   = "passbolt_db_static"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_integer" "passbolt_db_password_length" {
  min = 12
  max = 20
}
resource "random_password" "passbolt_db_password" {
  length  = random_integer.passbolt_db_password_length.result
  special = false
}

