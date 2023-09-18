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

resource "cloudflare_record" "boinc" {
  zone_id = var.domain.zone_id
  name    = "boinc"
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "boinc" {
  name = "linuxserver/boinc:18.04.1" # renovate_docker
}

resource "docker_image" "boinc" {
  name          = data.docker_registry_image.boinc.name
  pull_triggers = [data.docker_registry_image.boinc.sha256_digest]
}

resource "docker_container" "boinc" {
  image = docker_image.boinc.image_id
  name  = "boinc"
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
    label = "traefik.http.routers.boinc.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.boinc.rule"
    value = "Host(`home.${var.domain.name}`,`${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.boinc.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.boinc.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  env = [
    "CUSTOM_USER=boinc",
    "PASSWORD=${var.boinc_password}",
    "TZ=Europe/Paris"
  ]

  volumes {
    container_path = "/config"
    volume_name    = docker_volume.boinc.name
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "boinc" {
  name   = "boinc_static"
  driver = "local"
}
