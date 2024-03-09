terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "commander" {
  name = "jamesread/olivetin:2024.03.081" # renovate_docker
}

resource "docker_image" "commander" {
  name          = data.docker_registry_image.commander.name
  pull_triggers = [data.docker_registry_image.commander.sha256_digest]
}

resource "docker_container" "commander" {
  image = docker_image.commander.image_id
  name  = "commander"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.commander.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.commander.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.commander.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.commander.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.commander.middlewares"
    value = "sso"
  }
  networks_advanced {
    name = var.gateway
  }

  upload {
    file        = "/config/config.yaml"
    source      = "${path.module}/src/config.yaml"
    source_hash = filesha256("${path.module}/src/config.yaml")
  }

  volumes {
    container_path = "/srv"
    host_path      = "/commander_data"
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
