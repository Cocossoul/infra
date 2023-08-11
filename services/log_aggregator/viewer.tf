resource "cloudflare_record" "log_viewer" {
  zone_id = var.domain.zone_id
  name    = var.subdomain_log_viewer
  value   = var.domain.name
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "log_viewer" {
  name = "docker.elastic.co/kibana/kibana:8.9.0" # renovate_docker
}

resource "docker_image" "log_viewer" {
  name          = data.docker_registry_image.log_viewer.name
  pull_triggers = [data.docker_registry_image.log_viewer.sha256_digest]
}

resource "docker_container" "log_viewer" {
  image = docker_image.log_viewer.image_id
  name  = "log_viewer"
  ports {
    internal = 5601
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
    label = "traefik.http.routers.log_viewer.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.log_viewer.rule"
    value = "Host(`${var.subdomain_log_viewer}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.log_viewer.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.log_viewer.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.log_viewer.middlewares"
    value = "monitoring_auth"
  }
  networks_advanced {
    name = "gateway"
  }

  log_driver = "json-file"
  log_opts = {
    max-size: "15m"
    max-file: 3
  }

  env = [
    "ELASTICSEARCH_HOSTS=http://log_aggregator:9200",
    "ELASTICSEARCH_URL=http://log_aggregator:9200",
    "server.publicBaseUrl=https://${var.subdomain_log_viewer}.${var.domain.name}"
  ]

  restart = "unless-stopped"
}
