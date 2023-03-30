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

resource "null_resource" "reverse-proxy-internal-bridge_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "./build.sh"
  }
}

data "docker_registry_image" "reverse-proxy-internal-bridge" {
  name = "cocopaps/reverse-proxy-internal-bridge"
  depends_on = [
    null_resource.reverse-proxy-internal-bridge_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "reverse-proxy-internal-bridge" {
  name          = data.docker_registry_image.reverse-proxy-internal-bridge.name
  pull_triggers = [data.docker_registry_image.reverse-proxy-internal-bridge.sha256_digest]
}

resource "docker_container" "reverse-proxy-internal-bridge" {
  image = docker_image.reverse-proxy-internal-bridge.image_id
  name  = "reverse-proxy-internal-bridge"
  ports {
    internal = 80
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
    label = "traefik.http.routers.reverse-proxy-internal-bridge.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.reverse-proxy-internal-bridge.rule"
    value = "Host(`${ var.domain }`)"
  }
  labels {
    label = "traefik.http.routers.reverse-proxy-internal-bridge.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.reverse-proxy-internal-bridge.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.reverse-proxy-internal-bridge.name
  }

  restart = "unless-stopped"
}

resource "docker_volume" "reverse-proxy-internal-bridge" {
  name   = "reverse-proxy-internal-bridge_static"
  driver = "local"
}
