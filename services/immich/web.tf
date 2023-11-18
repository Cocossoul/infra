data "docker_registry_image" "immich_web" {
  name = "ghcr.io/immich-app/immich-web:v1.87.0" # renovate_docker
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

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
