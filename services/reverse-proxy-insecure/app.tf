terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "reverse-proxy-insecure_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "./build.sh"
  }
}

data "docker_registry_image" "reverse-proxy-insecure" {
  name = "cocopaps/reverse-proxy-insecure"
  depends_on = [
    null_resource.reverse-proxy-insecure_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "reverse-proxy-insecure" {
  name          = data.docker_registry_image.reverse-proxy-insecure.name
  pull_triggers = [data.docker_registry_image.reverse-proxy-insecure.sha256_digest]
}

resource "docker_container" "reverse-proxy-insecure" {
  image = docker_image.reverse-proxy-insecure.image_id
  name  = "reverse-proxy-insecure"
  ports {
    external = 80
    internal = 80
  }
  ports {
    external = 443
    internal = 443
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "gateway"
  }
  networks_advanced {
    name = "gateway"
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.reverse-proxy-insecure.name
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  restart = "unless-stopped"
}

resource "docker_volume" "reverse-proxy-insecure" {
  name   = "reverse-proxy-insecure_static"
  driver = "local"
}

resource "docker_network" "gateway" {
  name       = "gateway"
  driver     = "bridge"
  attachable = true
}
