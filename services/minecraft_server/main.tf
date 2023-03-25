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

resource "cloudflare_record" "minecraft_server" {
  zone_id = var.domain.zone_id
  name    = var.subdomain
  value   = var.machine.dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

resource "null_resource" "minecraft_server_build" {
  triggers = {
    build_dir_sha1 = sha1(join("", [for f in fileset("${path.module}/src", "*") : filesha1("${path.module}/src/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    environment = {
      MACHINE_NAME = var.machine.name
    }
    command = "./build.sh"
  }
}

data "docker_registry_image" "minecraft_server" {
  name = "cocopaps/minecraft_server:latest"
  depends_on = [
    null_resource.minecraft_server_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "minecraft_server" {
  name          = data.docker_registry_image.minecraft_server.name
  pull_triggers = [data.docker_registry_image.minecraft_server.sha256_digest]
}

resource "docker_container" "minecraft_server" {
  image = docker_image.minecraft_server.image_id
  name  = "minecraft_server"
  ports {
    external = 25565
    internal = 25565
  }
  volumes {
    container_path = "/server/runtime"
    host_path      = "/minecraft_server_data"
  }
  restart = "unless-stopped"
}
