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

resource "cloudflare_record" "gatus" {
  zone_id = var.domain_zone_id
  name    = var.subdomain
  value   = var.machine_dyndns_domain
  type    = "CNAME"
  ttl     = 3600
}

resource "null_resource" "gatus_build" {
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

data "docker_registry_image" "gatus" {
  name = "cocopaps/gatus${var.machine_name}"
  depends_on = [
    null_resource.gatus_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "gatus" {
  name          = data.docker_registry_image.gatus.name
  pull_triggers = [data.docker_registry_image.gatus.sha256_digest]
}

resource "docker_container" "gatus" {
  image = docker_image.gatus.image_id
  name  = "gatus"
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
    label = "traefik.http.routers.gatus.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.gatus.rule"
    value = "Host(`${var.subdomain}.${var.domain_name}`)"
  }
  labels {
    label = "traefik.http.routers.gatus.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.gatus.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = "gateway"
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.gatus.name
  }

  restart = "unless-stopped"
}

resource "docker_volume" "gatus" {
  name   = "gatus_static"
  driver = "local"
}
