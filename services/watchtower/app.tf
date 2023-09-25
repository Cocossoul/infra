terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.5"
    }
  }
}
data "docker_registry_image" "watchtower" {
  name = "containrrr/watchtower:1.5.3" # renovate_docker
}

resource "docker_image" "watchtower" {
  name          = data.docker_registry_image.watchtower.name
  pull_triggers = [data.docker_registry_image.watchtower.sha256_digest]
}

resource "docker_container" "watchtower" {
  image = docker_image.watchtower.image_id
  name  = "watchtower"

  env = [
    "TZ=Europe/Paris",
    "REPO_USER=cocopaps",
    "REPO_PASS=${var.docker_password}"
  ]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
