data "docker_registry_image" "immich_typesense" {
  name = "typesense/typesense:0.24.1" # renovate_docker
}

resource "docker_image" "immich_typesense" {
  name          = data.docker_registry_image.immich_typesense.name
  pull_triggers = [data.docker_registry_image.immich_typesense.sha256_digest]
}

resource "docker_container" "immich_typesense" {
  image = docker_image.immich_typesense.image_id
  name  = "immich_typesense"

  env = [
    "TYPESENSE_API_KEY=${random_password.typesense_api_key.result}",
    "TYPESENSE_DATA_DIR=/data",
      # remove this to get debug messages
    "GLOG_minloglevel=1"
  ]

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.immich_typesense_data.name
  }
  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "immich_typesense_data" {
  name   = "immich_typesense_data"
  driver = "local"
}

resource "random_password" "typesense_api_key" {
  length = 32
  special = false
  lifecycle {
    prevent_destroy = true
  }
}
