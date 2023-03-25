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

resource "cloudflare_record" "homer" {
  zone_id = var.domain.zone_id
  name    = "@"
  value   = var.machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "homer_alias" {
  zone_id = var.domain.zone_id
  name    = "home"
  value   = var.domain.name
  type    = "CNAME"
  ttl     = 3600
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "homer_build" {
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

data "docker_registry_image" "homer" {
  name = "cocopaps/homer${var.machine.name}"
  depends_on = [
    null_resource.homer_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "homer" {
  name          = data.docker_registry_image.homer.name
  pull_triggers = [data.docker_registry_image.homer.sha256_digest]
}

resource "docker_container" "homer" {
  image = docker_image.homer.image_id
  name  = "homer"
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
    label = "traefik.http.routers.homer.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.homer.rule"
    value = "Host(`home.${var.domain.name}`,`${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.homer.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.homer.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  restart = "unless-stopped"
}
