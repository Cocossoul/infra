terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "mealie" {
  name = "ghcr.io/mealie-recipes/mealie:v1.2.0" # renovate_docker
}

resource "docker_image" "mealie" {
  name          = data.docker_registry_image.mealie.name
  pull_triggers = [data.docker_registry_image.mealie.sha256_digest]
}

resource "docker_container" "mealie" {
  image = docker_image.mealie.image_id
  name  = "mealie"
  env = [
    "ALLOW_SIGNUP=false",
    "PUID=1000",
    "PGID=1000",
    "TZ=Europe/Paris",
    "MAX_WORKERS=1",
    "WEB_CONCURRENCY=1",
    "BASE_URL=https://${var.subdomain}.${var.domain.name}"
  ]
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.mealie.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.mealie.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.mealie.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.mealie.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  volumes {
    container_path = "/app/data/"
    volume_name    = docker_volume.mealie.name
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "mealie" {
  name   = "mealie_data"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
