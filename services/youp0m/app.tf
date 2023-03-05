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

resource "cloudflare_record" "youp0m" {
  zone_id = var.domain_zone_id
  name    = var.subdomain
  value   = var.machine_dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "youp0m" {
  name = "nemunaire/youp0m:latest"
}

resource "docker_image" "youp0m" {
  name          = data.docker_registry_image.youp0m.name
  pull_triggers = [data.docker_registry_image.youp0m.sha256_digest]
}

resource "docker_container" "youp0m" {
  image = docker_image.youp0m.image_id
  name  = "youp0m"
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
    label = "traefik.http.routers.youp0m.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.youp0m.rule"
    value = "Host(`${var.subdomain}.${var.domain_name}`)"
  }
  labels {
    label = "traefik.http.routers.youp0m.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.youp0m.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  volumes {
    container_path = "/srv/static"
    volume_name    = docker_volume.youp0m.name
  }

  restart = "unless-stopped"
}

resource "docker_volume" "youp0m" {
  name   = "youp0m_static"
  driver = "local"
}
