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

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "ru19h_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command = "./build.sh"
  }
}

data "docker_registry_image" "ru19h" {
  name = "cocopaps/ru19h:latest"
  depends_on = [
    null_resource.ru19h_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "ru19h" {
  name          = data.docker_registry_image.ru19h.name
  pull_triggers = [data.docker_registry_image.ru19h.sha256_digest]
}

resource "docker_container" "ru19h" {
  image = docker_image.ru19h.image_id
  name  = "ru19h"

  env = [
    "RU19H_TOKEN=${var.ru19h_token}"
  ]

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
