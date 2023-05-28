terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

data "docker_registry_image" "reverse-proxy" {
  name = "traefik:v2.9.8" # renovate_docker
}

resource "docker_image" "reverse-proxy" {
  name          = data.docker_registry_image.reverse-proxy.name
  pull_triggers = [data.docker_registry_image.reverse-proxy.sha256_digest]
}

resource "docker_container" "reverse-proxy" {
  image = docker_image.reverse-proxy.image_id
  name  = "reverse-proxy"
  ports {
    external = 80
    internal = 80
  }
  ports {
    external = 443
    internal = 443
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "gateway"
  }
  networks_advanced {
    name = "gateway"
  }

  upload {
    file = "/traefik.yml"
    source = "${path.module}/src/traefik.yml"
    source_hash = filesha256("${path.module}/src/traefik.yml")
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.reverse-proxy.name
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  restart = "unless-stopped"
}

resource "docker_volume" "reverse-proxy" {
  name   = "reverse-proxy_static"
  driver = "local"
}

resource "docker_network" "gateway" {
  name       = "gateway"
  driver     = "bridge"
  attachable = true
}
