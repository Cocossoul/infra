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

resource "cloudflare_record" "pdf-tools" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "pdf-tools" {
  name = "frooodle/s-pdf:0.14.4" # renovate_docker
}

resource "docker_image" "pdf-tools" {
  name          = data.docker_registry_image.pdf-tools.name
  pull_triggers = [data.docker_registry_image.pdf-tools.sha256_digest]
}

resource "docker_container" "pdf-tools" {
  image = docker_image.pdf-tools.image_id
  name  = "pdf-tools"

  ports {
    internal = 8080
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
    label = "traefik.http.routers.pdf-tools.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.middlewares"
    value = "sso"
  }
  networks_advanced {
    name = "gateway"
  }

  env = [
    "TZ=Europe/Paris",
    "SYSTEM_DEFAULTLOCALE=fr-FR"
  ]

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
