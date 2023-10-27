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

data "docker_registry_image" "gatus" {
  name = "twinproduction/gatus:v5.6.0" # renovate_docker
}

resource "docker_image" "gatus" {
  name          = data.docker_registry_image.gatus.name
  pull_triggers = [data.docker_registry_image.gatus.sha256_digest]
}

resource "docker_container" "gatus" {
  image = docker_image.gatus.image_id
  name  = "gatus"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.gatus.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.gatus.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.gatus.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.gatus.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  upload {
    file = "/config/config.yaml"
    content = templatefile("${path.module}/src/config.yaml",
        {
            discord_webhook = var.discord_webhook
        }
    )
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.gatus.name
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "gatus" {
  name   = "gatus_static"
  driver = "local"
}
