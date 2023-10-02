data "docker_registry_image" "crowdsec" {
  name = "crowdsecurity/crowdsec:v1.5.4" # renovate_docker
}

resource "docker_image" "crowdsec" {
  name          = data.docker_registry_image.crowdsec.name
  pull_triggers = [data.docker_registry_image.crowdsec.sha256_digest]
}

data "docker_registry_image" "crowdsec_bouncer" {
  name = "fbonalair/traefik-crowdsec-bouncer:latest" # renovate_docker
}

resource "docker_image" "crowdsec_bouncer" {
  name          = data.docker_registry_image.crowdsec_bouncer.name
  pull_triggers = [data.docker_registry_image.crowdsec_bouncer.sha256_digest]
}

resource "docker_container" "crowdsec" {
  image = docker_image.crowdsec.image_id
  name  = "crowdsec"

  env = [
      "COLLECTIONS=crowdsecurity/traefik"
  ]

  upload {
    file = "/etc/crowdsec/acquis.yaml"
    source = "${path.module}/src/crowdsec_acquis.yaml"
    source_hash = filesha256("${path.module}/src/crowdsec_acquis.yaml")
  }

  volumes {
    container_path = "/var/log/traefik"
    volume_name    = docker_volume.reverse-proxy_logs.name
    read_only = true
  }

  volumes {
    container_path = "/var/lib/crowdsec/data"
    volume_name    = docker_volume.crowdsec_db.name
  }
  volumes {
    container_path = "/etc/crowdsec/"
    volume_name    = docker_volume.crowdsec_config.name
  }

  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_container" "crowdsec_bouncer" {
  image = docker_image.crowdsec_bouncer.image_id
  name  = "crowdsec_bouncer"

  env = [
    "CROWDSEC_BOUNCER_API_KEY=${var.crowdsec_api_key}",
    "CROWDSEC_AGENT_HOST=${docker_container.crowdsec.name}:8080"
  ]

  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "crowdsec_db" {
  name   = "crowdsec_db"
  driver = "local"
}

resource "docker_volume" "crowdsec_config" {
  name   = "crowdsec_config"
  driver = "local"
}
