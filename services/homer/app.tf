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

resource "cloudflare_record" "homer" {
  zone_id = var.domain.zone_id
  name    = "@"
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "homer_alias" {
  zone_id = var.domain.zone_id
  name    = "home"
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "homer" {
  name = "b4bz/homer:v23.05.1" # renovate_docker
}

resource "docker_image" "homer" {
  name          = data.docker_registry_image.homer.name
  pull_triggers = [data.docker_registry_image.homer.sha256_digest]
}

resource "docker_container" "homer" {
  image = docker_image.homer.image_id
  name  = "homer"
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
    name = "gateway"
  }

  upload {
    file = "/www/assets/config.yml"
    source = "${path.module}/src/config.yml"
    source_hash = filesha256("${path.module}/src/config.yml")
  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "localhost:24224"
    tag = "homer"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
