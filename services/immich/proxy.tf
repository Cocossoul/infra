data "docker_registry_image" "immich_proxy" {
  name = "ghcr.io/immich-app/immich-proxy:${local.version}"
}

resource "docker_image" "immich_proxy" {
  name          = data.docker_registry_image.immich_proxy.name
  pull_triggers = [data.docker_registry_image.immich_proxy.sha256_digest]
}

resource "docker_container" "immich_proxy" {
  image = docker_image.immich_proxy.image_id
  name  = "immich_proxy"

  env = [
    "IMMICH_SERVER_URL=http://${docker_container.immich_server.name}:3001",
    "IMMICH_WEB_URL=http://${docker_container.immich_web.name}:3000",
    "IMMICH_API_URL_EXTERNAL=https://${var.subdomain}.${var.domain.name}"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.immich_proxy.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich_proxy.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
