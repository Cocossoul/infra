data "docker_registry_image" "immich_db" {
  name = "postgres:14-alpine" # renovate_docker
}

resource "docker_image" "immich_db" {
  name          = data.docker_registry_image.immich_db.name
  pull_triggers = [data.docker_registry_image.immich_db.sha256_digest]
}

resource "docker_container" "immich_db" {
  image = docker_image.immich_db.image_id
  name  = "immich_db"

  env = [
    "POSTGRES_PASSWORD=${random_password.immich_db.result}",
    "POSTGRES_USER=postgres",
    "POSTGRES_DB=immich"
  ]

  command = ["--max-allowed-packet=128M", "--innodb-log-file-size=64M"]

  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = "/mnt/raid/immich_data/immich_db"
  }
  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "random_integer" "immich_db_password_length" {
  min = 12
  max = 20
}
resource "random_password" "immich_db" {
  length           = random_integer.immich_db_password_length.result
  special          = false
}
