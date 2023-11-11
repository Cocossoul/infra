terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
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
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
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

  networks_advanced {
    name = var.gateway
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
