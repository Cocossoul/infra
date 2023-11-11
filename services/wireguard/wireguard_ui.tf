data "docker_registry_image" "wireguard_ui" {
  name = "ngoduykhanh/wireguard-ui:0.5.2" # renovate_docker
}

resource "docker_image" "wireguard_ui" {
  name          = data.docker_registry_image.wireguard_ui.name
  pull_triggers = [data.docker_registry_image.wireguard_ui.sha256_digest]
}

resource "docker_container" "wireguard_ui" {
  image = docker_image.wireguard_ui.image_id
  name  = "wireguard_ui"

  env = [
    "TZ=Europe/Paris",
    "WGUI_PASSWORD=${var.password}",
    "WGUI_DNS=192.168.1.24",
    "WGUI_SERVER_POST_UP_SCRIPT=iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
    "WGUI_SERVER_POST_DOWN_SCRIPT=iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE",
    "WGUI_MANAGE_START=true",
    "WGUI_MANAGE_RESTART=true",
    "WGUI_ENDPOINT_ADDRESS=${var.machine.dyndns_address}"
  ]

  capabilities {
    add = ["NET_ADMIN"]
  }

  ports {
    external = 8080
    internal = 80
  }

  volumes {
    container_path = "/etc/wireguard"
    volume_name    = docker_volume.wireguard_data.name
  }

  volumes {
    container_path = "/app/db"
    volume_name    = docker_volume.wireguard_ui_db.name
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.wireguard_ui.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.wireguard_ui.rule"
    value = "Host(`${var.wireguard_ui_subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.wireguard_ui.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.services.wireguard_ui.loadbalancer.server.port"
    value = "80"
  }
  labels {
    label = "traefik.http.routers.wireguard_ui.tls.certresolver"
    value = "letsencrypt"
  }

  networks_advanced {
    name = var.gateway
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "wireguard_ui_db" {
  name   = "wireguard_ui_db"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
