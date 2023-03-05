terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

resource "null_resource" "reverse-proxy_build" {
  triggers = {
    build_dir_sha1 = sha1(join("", [for f in fileset("${path.module}/src", "*") : filesha1("${path.module}/src/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    environment = {
      MACHINE_NAME = var.machine_name
    }
    command = "./build.sh"
  }
}

data "docker_registry_image" "reverse-proxy" {
  name = "cocopaps/reverse-proxy${var.machine_name}"
  depends_on = [
    null_resource.reverse-proxy_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "reverse-proxy" {
  name          = data.docker_registry_image.reverse-proxy.name
  pull_triggers = [data.docker_registry_image.reverse-proxy.sha256_digest]
}

resource "docker_container" "reverse-proxy" {
  image = docker_image.reverse-proxy.image_id
  name  = "reverse-proxy"
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
    volume_name    = docker_volume.reverse-proxy.name
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  restart = "unless-stopped"
}

resource "docker_volume" "reverse-proxy" {
  name   = "reverse-proxy_static"
  driver = "local"
}

resource "docker_network" "gateway" {
  name       = "gateway"
  driver     = "bridge"
  attachable = true
}
