data "docker_registry_image" "immich_db" {
  name = "postgres:14-alpine@sha256:28407a9961e76f2d285dc6991e8e48893503cc3836a4755bbc2d40bcc272a441" # renovate_docker
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
