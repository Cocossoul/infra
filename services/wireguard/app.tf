terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "wireguard" {
  name = "weejewel/wg-easy:7" # renovate_docker
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
    "WG_HOSTNAME=${var.machine.dyndns_address}",
    "WG_PORT=51820",
    "PORT=8080", // Port of the web ui
    "WG_DEFAULT_DNS=127.0.0.1",
    "PASSWORD=${var.password}"
  ]

  capabilities {
    add = ["NET_ADMIN", "SYS_MODULE"]
  }

  sysctls = {
    "net.ipv4.conf.all.src_valid_mark" = "1",
    "net.ipv4.ip_forward" = "1"
  }

  ports {
    external = 51820
    internal = 51820
    protocol = "udp"
  }

  ports {
    external = 8080
    internal = 8080
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