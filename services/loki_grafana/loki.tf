terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "loki" {
  name = "grafana/loki:main-58eaad9-amd64" # renovate_docker
}

resource "docker_image" "loki" {
  name          = data.docker_registry_image.loki.name
  pull_triggers = [data.docker_registry_image.loki.sha256_digest]
}

resource "docker_container" "loki" {
  image = docker_image.loki.image_id
  name  = "loki"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.loki.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.loki.rule"
    value = "Host(`${var.subdomain_loki}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.loki.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.loki.middlewares"
    value = "loki_auth"
  }
  labels {
    label = "traefik.http.routers.loki.tls.certresolver"
    value = "letsencrypt"
  }

  networks_advanced {
    name = var.gateway
  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "localhost:24224"
  }

  upload {
    file        = "/etc/loki/config.yaml"
    source      = "${path.module}/src/loki_config.yaml"
    source_hash = filesha256("${path.module}/src/loki_config.yaml")
  }

  command = [
    "-config.file=/etc/loki/config.yaml",
  ]

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
