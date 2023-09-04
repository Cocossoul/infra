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

resource "cloudflare_record" "netdata" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "netdata" {
  name = "netdata/netdata:v1.42.2" # renovate_docker
}

resource "docker_image" "netdata" {
  name          = data.docker_registry_image.netdata.name
  pull_triggers = [data.docker_registry_image.netdata.sha256_digest]
}

resource "docker_container" "netdata" {
  image = docker_image.netdata.image_id
  name  = "netdata"
  ports {
    internal = 19999
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
    label = "traefik.http.routers.netdata.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.netdata.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.netdata.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.netdata.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.netdata.middlewares"
    value = "monitoring_auth"
  }
  networks_advanced {
    name = "gateway"
  }

  volumes {
    host_path      = "/etc/passwd"
    container_path = "/host/etc/passwd"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/group"
    container_path = "/host/etc/group"
    read_only      = true
  }
  volumes {
    host_path      = "/proc"
    container_path = "/host/proc"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  capabilities {
    add = ["SYS_PTRACE"]
  }

  security_opts = ["apparmor:unconfined"]

  upload {
    file = "/usr/lib/netdata/conf.d/health_alarm_notify.conf"
    content_base64 = local.health_alarm_notify
  }

  log_driver = "json-file"
  log_opts = {
    max-size: "15m"
    max-file: 3
  }

  restart = "unless-stopped"
}
