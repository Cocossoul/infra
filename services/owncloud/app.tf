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

resource "cloudflare_record" "owncloud" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "owncloud" {
  name = "owncloud/server:10.12" # renovate_docker
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
    "OWNCLOUD_DOMAIN=${var.subdomain}.${var.domain.name}",
    "OWNCLOUD_TRUSTED_DOMAINS=${var.subdomain}.${var.domain.name}",
    "OWNCLOUD_ADMIN_USERNAME=${var.owncloud_admin_username}",
    "OWNCLOUD_ADMIN_PASSWORD=${var.owncloud_admin_password}",
    "OWNCLOUD_REDIS_ENABLED=true",
    "OWNCLOUD_REDIS_HOST=${resource.docker_container.redis.name}",
    "OWNCLOUD_DB_TYPE=mysql",
    "OWNCLOUD_DB_NAME=owncloud",
    "OWNCLOUD_DB_USERNAME=owncloud",
    "OWNCLOUD_DB_PASSWORD=${var.owncloud_db_password}",
    "OWNCLOUD_DB_HOST=${docker_container.owncloud_db.name}",
    "OWNCLOUD_MYSQL_UTF8MB4=true",
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
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
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
    host_path      = "/mnt/raid/owncloud_data/owncloud"
  }

  healthcheck {
    test     = ["CMD", "/usr/bin/healthcheck"]
    interval = "30s"
    timeout  = "10s"
    retries  = 5

  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "localhost:24224"
    tag = "owncloud"
  }

  restart = "unless-stopped"
}
