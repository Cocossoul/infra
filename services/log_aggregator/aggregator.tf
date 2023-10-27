terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

data "docker_registry_image" "log_aggregator" {
  name = "docker.elastic.co/elasticsearch/elasticsearch:8.10.4" # renovate_docker
}

resource "docker_image" "log_aggregator" {
  name          = data.docker_registry_image.log_aggregator.name
  pull_triggers = [data.docker_registry_image.log_aggregator.sha256_digest]
}

resource "docker_container" "log_aggregator" {
  image = docker_image.log_aggregator.image_id
  name  = "log_aggregator"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
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
    label = "traefik.http.routers.log_aggregator.middlewares"
    value = "elasticsearch_auth"
  }
  labels {
    label = "traefik.http.routers.log_aggregator.tls.certresolver"
    value = "letsencrypt"
  }
  volumes {
    container_path = "/usr/share/elasticsearch/data"
    volume_name    = docker_volume.elasticsearch.name
  }
  networks_advanced {
    name = var.gateway
  }
  env = [
      "discovery.type=single-node",
      "xpack.security.enabled=false",
      "xpack.security.http.ssl.enabled=false",
      "xpack.security.transport.ssl.enabled=false"
  ]


  log_driver = "json-file"
  log_opts = {
    max-size: "15m"
    max-file: 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "elasticsearch" {
  name   = "elasticsearch_static"
  driver = "local"
}
