terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

resource "cloudflare_record" "gatus" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "gatus" {
  name = "twinproduction/gatus:v5.3.1"
}

resource "docker_image" "gatus" {
  name          = data.docker_registry_image.gatus.name
  pull_triggers = [data.docker_registry_image.gatus.sha256_digest]
}

resource "docker_container" "gatus" {
  image = docker_image.gatus.image_id
  name  = "gatus"
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
    name = "gateway"
  }

  upload {
    file = "/config/config.yaml"
    source = "${path.module}/src/config.yaml"
    source_hash = filesha256("${path.module}/src/config.yaml")
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.gatus.name
  }

  restart = "unless-stopped"
}

resource "docker_volume" "gatus" {
  name   = "gatus_static"
  driver = "local"
}
