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

resource "cloudflare_record" "log_aggregator" {
  zone_id = var.domain.zone_id
  name    = var.subdomain_log_aggregator
  value   = var.domain.name
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "log_aggregator" {
  name = "docker.elastic.co/elasticsearch/elasticsearch:8.9.0" # renovate_docker
}

resource "docker_image" "log_aggregator" {
  name          = data.docker_registry_image.log_aggregator.name
  pull_triggers = [data.docker_registry_image.log_aggregator.sha256_digest]
}

resource "docker_container" "log_aggregator" {
  image = docker_image.log_aggregator.image_id
  name  = "log_aggregator"
  ports {
    internal = 9200
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
    label = "traefik.http.routers.log_aggregator.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.log_aggregator.rule"
    value = "Host(`${var.subdomain_log_aggregator}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.log_aggregator.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.log_aggregator.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }
  env = [
      "discovery.type=single-node",
      "xpack.security.http.ssl.enabled=false"
      "ELASTIC_USERNAME=elastic"
      "ELASTIC_PASSWORD=changeme"
  ]

  restart = "unless-stopped"
}
