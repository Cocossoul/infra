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

resource "cloudflare_record" "immich_proxy" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "immich_proxy" {
  name = "ghcr.io/immich-app/immich-proxy:v1.82.0" # renovate_docker
}

resource "docker_image" "immich_proxy" {
  name          = data.docker_registry_image.immich_proxy.name
  pull_triggers = [data.docker_registry_image.immich_proxy.sha256_digest]
}

resource "docker_container" "immich_proxy" {
  image = docker_image.immich_proxy.image_id
  name  = "immich_proxy"

  env = [
    "IMMICH_SERVER_URL=http://${docker_container.immich_server.name}:3001",
    "IMMICH_WEB_URL=http://${docker_container.immich_web.name}:3000",
    "IMMICH_API_URL_EXTERNAL=https://${var.subdomain}.${var.domain.name}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "gateway"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}