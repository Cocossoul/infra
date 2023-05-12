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

resource "cloudflare_record" "portfolio" {
  zone_id = var.domain.zone_id
  name    = "@"
  value   = var.machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "portfolio_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    environment = {
      MACHINE_NAME = var.machine.name
    }
    command = "./build.sh"
  }
}

data "docker_registry_image" "portfolio" {
  name = "cocopaps/portfolio:latest"
  depends_on = [
    null_resource.portfolio_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "portfolio" {
  name          = data.docker_registry_image.portfolio.name
  pull_triggers = [data.docker_registry_image.portfolio.sha256_digest]
}

resource "docker_container" "portfolio" {
  image = docker_image.portfolio.image_id
  name  = "portfolio"
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
    label = "traefik.http.routers.portfolio.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.portfolio.rule"
    value = "Host(`${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.portfolio.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.portfolio.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }
  restart = "unless-stopped"
}
