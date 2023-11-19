data "docker_registry_image" "grafana" {
  name = "grafana/grafana:9.5.14" # renovate_docker
}

resource "docker_image" "grafana" {
  name          = data.docker_registry_image.grafana.name
  pull_triggers = [data.docker_registry_image.grafana.sha256_digest]
}

resource "docker_container" "grafana" {
  image = docker_image.grafana.image_id
  name  = "grafana"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.grafana.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "Host(`${var.subdomain_grafana}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.grafana.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.grafana.tls.certresolver"
    value = "letsencrypt"
  }

  networks_advanced {
    name = var.gateway
  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "fluentd:24224"
  }

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_SECURITY_ADMIN_USER=admin"
  ]

  volumes {
    volume_name    = docker_volume.grafana.name
    container_path = "/var/lib/grafana"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "grafana" {
  name   = "grafana_data"
  driver = "local"
}
