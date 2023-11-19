terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "fluentd" {
  name = "grafana/fluent-plugin-loki:main-58eaad9-amd64" # renovate_docker
}

resource "docker_image" "fluentd" {
  name          = data.docker_registry_image.fluentd.name
  pull_triggers = [data.docker_registry_image.fluentd.sha256_digest]
}

resource "docker_container" "fluentd" {
  image = docker_image.fluentd.image_id
  name  = "fluentd"

  ports {
    internal = 24224
    external = 24224
  }

  env = [
    "LOKI_URL=${var.loki.url}",
    "LOKI_USERNAME=loki",
    "LOKI_PASSWORD=${var.loki.password}",
    "MACHINE_NAME=${var.machine.name}"
  ]

  volumes {
    volume_name    = docker_volume.fluentd_logs.name
    container_path = "/var/log"
  }

  volumes {
    host_path      = "/dev/log"
    container_path = "/dev/log"
    read_only      = true
  }

  volumes {
    host_path      = "/etc/machine-id"
    container_path = "/etc/machine-id"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run/systemd/journal"
    container_path = "/var/run/systemd/journal"
    read_only      = true
  }

  command = [
    "fluentd",
    "-v",
    "-p",
    "/fluentd/plugins",
  ]

  upload {
    file        = "/fluentd/etc/loki/loki.conf"
    source      = "${path.module}/src/loki.conf"
    source_hash = filesha256("${path.module}/src/loki.conf")
  }

  networks_advanced {
    name = var.gateway
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "fluentd_logs" {
  name   = "fluentd_logs"
  driver = "local"
}
