terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "homer" {
  name = "b4bz/homer:v23.10.1" # renovate_docker
}

resource "docker_image" "homer" {
  name          = data.docker_registry_image.homer.name
  pull_triggers = [data.docker_registry_image.homer.sha256_digest]
}

resource "docker_container" "homer" {
  image = docker_image.homer.image_id
  name  = "homer"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.homer.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.homer.rule"
    value = "Host(`home.${var.domain.name}`,`${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.homer.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.homer.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  upload {
    file        = "/www/assets/config.yml"
    source      = "${path.module}/src/${var.config_path}"
    source_hash = filesha256("${path.module}/src/${var.config_path}")
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
