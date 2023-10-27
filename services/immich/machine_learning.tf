data "docker_registry_image" "immich_machine_learning" {
  name = "ghcr.io/immich-app/immich-machine-learning:v1.82.0" # renovate_docker
}

resource "docker_image" "immich_machine_learning" {
  name          = data.docker_registry_image.immich_machine_learning.name
  pull_triggers = [data.docker_registry_image.immich_machine_learning.sha256_digest]
}

resource "docker_container" "immich_machine_learning" {
  image = docker_image.immich_machine_learning.image_id
  name  = "immich_machine_learning"

  volumes {
    container_path = "/cache"
    volume_name    = docker_volume.immich_machine_learning_cache.name
  }
  networks_advanced {
    name = "gateway"
    aliases = [ "immich-machine-learning" ]
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "immich_machine_learning_cache" {
  name   = "machine_learning_cache"
  driver = "local"
}
