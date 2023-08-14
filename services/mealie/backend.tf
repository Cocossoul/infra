data "docker_registry_image" "mealie_backend" {
  name = "hkotel/mealie:api-v1.0.0beta-5" # renovate_docker
}

resource "docker_image" "mealie_backend" {
  name          = data.docker_registry_image.mealie_backend.name
  pull_triggers = [data.docker_registry_image.mealie_backend.sha256_digest]
}

resource "docker_container" "mealie_backend" {
  image = docker_image.mealie_backend.image_id
  name  = "mealie_backend"
  ports {
    internal = 9000
  }
  env = [
    "ALLOW_SIGNUP=false",
    "API_URL=http://${docker_container.mealie_backend.name}:9000",
    "PUID=1000",
    "PGID=1000",
    "TZ=Europe/Paris",
    "MAX_WORKERS=1",
    "WEB_CONCURRENCY=1",
    "BASE_URL=https://${var.subdomain}.${var.domain.name}"
  ]
  networks_advanced {
    name = "gateway"
  }

  volumes {
    container_path = "/app/data/"
    volume_name    = docker_volume.mealie.name
  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "localhost:24224"
    tag = "mealie_backend"
  }

  restart = "unless-stopped"
}
