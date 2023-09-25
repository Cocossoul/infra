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

resource "cloudflare_record" "commander" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "commander" {
  name = "jamesread/olivetin:2023.03.25" # renovate_docker
}

resource "docker_image" "commander" {
  name          = data.docker_registry_image.commander.name
  pull_triggers = [data.docker_registry_image.commander.sha256_digest]
}

resource "docker_container" "commander" {
  image = docker_image.commander.image_id
  name  = "commander"
  ports {
    internal = 1337
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "gateway"
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
    value = "monitoring_auth"
  }
  networks_advanced {
    name = "gateway"
  }

  upload {
    file = "/config/config.yaml"
    source = "${path.module}/src/config.yaml"
    source_hash = filesha256("${path.module}/src/config.yaml")
  }

  volumes {
    container_path = "/srv"
    host_path      = "/commander_data"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
