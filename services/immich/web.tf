data "docker_registry_image" "immich_web" {
  name = "ghcr.io/immich-app/web:v1.82.0" # renovate_docker
}

resource "docker_image" "immich_web" {
  name          = data.docker_registry_image.immich_web.name
  pull_triggers = [data.docker_registry_image.immich_web.sha256_digest]
}

resource "docker_container" "immich_web" {
  image = docker_image.immich_web.image_id
  name  = "immich_web"

  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}