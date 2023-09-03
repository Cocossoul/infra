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

resource "cloudflare_record" "tbeteouquoi" {
  zone_id = var.domain.zone_id
  name    = "@"
  value   = var.machine.address
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "tbeteouquoi_build" {
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

data "docker_registry_image" "tbeteouquoi" {
  name = "cocopaps/tbeteouquoi:latest"
  depends_on = [
    null_resource.tbeteouquoi_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "tbeteouquoi" {
  name          = data.docker_registry_image.tbeteouquoi.name
  pull_triggers = [data.docker_registry_image.tbeteouquoi.sha256_digest]
}

resource "docker_container" "tbeteouquoi" {
  image = docker_image.tbeteouquoi.image_id
  name  = "tbeteouquoi"
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
    label = "traefik.http.routers.tbeteouquoi.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.rule"
    value = "Host(`${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.tls.certresolver"
    value = "letsencrypt"
  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "localhost:24224"
    tag = "tbeteouquoi"
  }

  networks_advanced {
    name = "gateway"
  }
  restart = "unless-stopped"
}
