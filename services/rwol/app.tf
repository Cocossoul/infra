terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_record" "rwol" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "docker_registry_image" "rwol" {
  name = "ex0nuss/remote-wake-sleep-on-lan-docker:latest"
}

resource "docker_image" "rwol" {
  name          = data.docker_registry_image.rwol.name
  pull_triggers = [data.docker_registry_image.rwol.sha256_digest]
}

resource "docker_container" "rwol" {
  image = docker_image.rwol.image_id
  name  = "rwol"
  ports {
    internal = 8080
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
    label = "traefik.http.routers.rwol.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.rwol.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.rwol.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.rwol.tls.certresolver"
    value = "letsencrypt"
  }
  env = [
      "APACHE2_PORT=8080",
      "PASSPHRASE=${var.rwol_password}",
      "RWSOLS_COMPUTER_NAME='PCGamer'",
      "RWSOLS_COMPUTER_MAC='${var.gamerpc_mac_address}'",
      "RWSOLS_COMPUTER_IP='192.168.1.75'"
  ]
  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
