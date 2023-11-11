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

resource "null_resource" "nightly_maintenance_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "./build.sh"
  }
}

data "docker_registry_image" "nightly_maintenance" {
  name = "cocopaps/nightly_maintenance:latest"
  depends_on = [
    null_resource.nightly_maintenance_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "nightly_maintenance" {
  name          = data.docker_registry_image.nightly_maintenance.name
  pull_triggers = [data.docker_registry_image.nightly_maintenance.sha256_digest]
}

resource "docker_container" "nightly_maintenance" {
  image = docker_image.nightly_maintenance.image_id
  name  = "nightly_maintenance"

  upload {
    file       = "/task.sh"
    content    = local.task
    executable = true
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
