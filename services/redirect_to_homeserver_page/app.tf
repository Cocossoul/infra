terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

data "docker_registry_image" "redirect_to_homeserver_page" {
  name = "nginx:1.25.3-alpine3.18-slim" # renovate_docker
}

resource "docker_image" "redirect_to_homeserver_page" {
  name          = data.docker_registry_image.redirect_to_homeserver_page.name
  pull_triggers = [data.docker_registry_image.redirect_to_homeserver_page.sha256_digest]
}

resource "docker_container" "redirect_to_homeserver_page" {
  image = docker_image.redirect_to_homeserver_page.image_id
  name  = "redirect_to_homeserver_page"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.redirect_to_homeserver_page.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.redirect_to_homeserver_page.rule"
    value = join(" && ", [
      for hostname in var.hostnames:
        "Host(`${hostname}`)"
    ])
  }
  labels {
    label = "traefik.http.routers.redirect_to_homeserver_page.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.redirect_to_homeserver_page.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  upload {
    file = "/usr/share/nginx/html/index.html"
    source = "${path.module}/src/index.html"
    source_hash = filesha256("${path.module}/src/index.html")
  }

  env = [
    "TZ=Europe/Paris"
  ]

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
