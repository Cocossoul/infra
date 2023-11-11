terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "wireguard" {
  name = "linuxserver/wireguard:1.0.20210914" # renovate_docker
}

resource "docker_image" "wireguard" {
  name          = data.docker_registry_image.wireguard.name
  pull_triggers = [data.docker_registry_image.wireguard.sha256_digest]
}

resource "docker_container" "wireguard" {
  image = docker_image.wireguard.image_id
  name  = "wireguard"

  env = [
    "TZ=Europe/Paris",
    "SERVERPORT=51820"
  ]

  capabilities {
    add = ["NET_ADMIN", "SYS_MODULE"]
  }

  sysctls = {
    "net.ipv4.conf.all.src_valid_mark" = "1",
  }

  ports {
    external = 51820
    internal = 51820
    protocol = "udp"
  }

  volumes {
    container_path = "/etc/wireguard"
    volume_name    = docker_volume.wireguard_data.name
  }

  network_mode = "host"

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "wireguard_data" {
  name   = "wireguard_data"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
