data "docker_registry_image" "immich_web" {
  name = "ghcr.io/immich-app/immich-web:v1.86.0" # renovate_docker
}

resource "docker_image" "immich_web" {
  name          = data.docker_registry_image.immich_web.name
  pull_triggers = [data.docker_registry_image.immich_web.sha256_digest]
}

resource "docker_container" "immich_web" {
  image = docker_image.immich_web.image_id
  name  = "immich-web"

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
