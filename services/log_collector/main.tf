terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "log_collector_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command = "./build.sh"
  }
}

data "docker_registry_image" "log_collector" {
  name = "cocopaps/log_collector:latest"
  depends_on = [
    null_resource.log_collector_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "log_collector" {
  name          = data.docker_registry_image.log_collector.name
  pull_triggers = [data.docker_registry_image.log_collector.sha256_digest]
}

resource "docker_container" "log_collector" {
  image = docker_image.log_collector.image_id
  name  = "log_collector"

  ports {
    external = 24224
    internal = 24224
  }

  ports {
    external = 24224
    internal = 24224
    protocol = "udp"
  }

  upload {
    file = "/fluentd/etc/fluent.conf"
    content = can(var.log_aggregator.password) ? local.fluent_basic_auth_conf : local.fluentconf
  }

  networks_advanced {
    name = "gateway"
  }
  log_driver = "json-file"
  log_opts = {
    max-size: "15m"
    max-file: 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
