terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

resource "cloudflare_record" "owncloud" {
  zone_id = var.domain_zone_id
  name    = var.subdomain
  value   = var.machine_dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "owncloud" {
  name = "owncloud/server:10.11"
}

resource "docker_image" "owncloud" {
  name          = data.docker_registry_image.owncloud.name
  pull_triggers = [data.docker_registry_image.owncloud.sha256_digest]
}

resource "docker_container" "owncloud" {
  image = docker_image.owncloud.image_id
  name  = "owncloud"
  ports {
    internal = 8080
  }
  env = [
    "OWNCLOUD_DOMAIN=${var.subdomain}.${var.domain_name}",
    "OWNCLOUD_TRUSTED_DOMAINS=${var.subdomain}.${var.domain_name}",
    "OWNCLOUD_ADMIN_USERNAME=${var.owncloud_admin_username}",
    "OWNCLOUD_ADMIN_PASSWORD=${var.owncloud_admin_password}",
    "OWNCLOUD_REDIS_ENABLED=true",
    "OWNCLOUD_REDIS_HOST=${resource.docker_container.redis.name}",
    "HTTP_PORT=8080"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "gateway"
  }
  labels {
    label = "traefik.http.routers.owncloud.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.owncloud.rule"
    value = "Host(`${var.subdomain}.${var.domain_name}`)"
  }
  labels {
    label = "traefik.http.routers.owncloud.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.owncloud.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  volumes {
    container_path = "/mnt/data"
    host_path      = "/owncloud_data"
  }

  healthcheck {
    test     = ["CMD", "/usr/bin/healthcheck"]
    interval = "30s"
    timeout  = "10s"
    retries  = 5

  }

  restart = "unless-stopped"
}
