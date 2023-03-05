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

resource "cloudflare_record" "netdata" {
  zone_id = var.domain_zone_id
  name    = var.subdomain
  value   = var.machine_dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

data "docker_registry_image" "netdata" {
  name = "netdata/netdata:latest"
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
    value = "Host(`${var.subdomain}.${var.domain_name}`)"
  }
  labels {
    label = "traefik.http.routers.netdata.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.netdata.tls.certresolver"
    value = "letsencrypt"
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

  restart = "unless-stopped"
}
