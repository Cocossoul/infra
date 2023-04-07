data "docker_registry_image" "owncloud_db" {
  name = "mariadb:10.6"
}

resource "docker_image" "owncloud_db" {
  name          = data.docker_registry_image.owncloud_db.name
  pull_triggers = [data.docker_registry_image.owncloud_db.sha256_digest]
}

resource "docker_container" "owncloud_db" {
  image = docker_image.owncloud_db.image_id
  name  = "owncloud_db"
  ports {
    internal = 3306
  }

  env = [
      "MYSQL_RANDOM_ROOT_PASSWORD=\"true\"",
      "MYSQL_DATABASE=owncloud",
      "MYSQL_USER=owncloud",
      "MYSQL_PASSWORD=${random_password.owncloud_db_password.result}"
  ]

  command = ["--max-allowed-packet=128M", "--innodb-log-file-size=64M"]

  healthcheck {
    test = ["CMD", "mysqladmin", "ping", "-u", "root", "--password=owncloud"]
    interval = "10s"
    timeout = "5s"
    retries = 5
  }

  volumes {
    container_path = "/var/lib/mysql"
    volume_name    = docker_volume.owncloud_db.name
  }
  networks_advanced {
    name = "gateway"
  }

  restart = "unless-stopped"
}

resource "docker_volume" "owncloud_db" {
  name   = "owncloud_db_static"
  driver = "local"
}

resource "random_integer" "owncloud_db_password_length" {
  min = 12
  max = 20
}
resource "random_password" "owncloud_db_password" {
  length           = random_integer.owncloud_db_password_length.result
  special          = false
}


