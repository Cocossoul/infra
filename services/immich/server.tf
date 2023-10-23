data "docker_registry_image" "immich_server" {
  name = "ghcr.io/immich-app/immich-server:v1.82.0" # renovate_docker
}

resource "docker_image" "immich_server" {
  name          = data.docker_registry_image.immich_server.name
  pull_triggers = [data.docker_registry_image.immich_server.sha256_digest]
}

resource "docker_container" "immich_server" {
  image = docker_image.immich_server.image_id
  name  = "immich-server"

  env = [
    "TYPESENSE_API_KEY=${random_password.typesense_api_key.result}",
    "MYSQL_DATABASE=owncloud",
    "MYSQL_USER=owncloud",
    "DB_PASSWORD=${random_password.immich_db.result}",
    "DB_HOSTNAME=immich-postgres",
    "DB_USERNAME=postgres",
    "DB_DATABASE_NAME=immich",
    "REDIS_HOSTNAME=immich_redis"
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = "gateway"
  }
  labels {
    label = "traefik.http.routers.immich_server.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.immich_server.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`) && PathPrefix(`/api/`)"
  }
  labels {
    label = "traefik.http.routers.immich_server.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich_server.tls.certresolver"
    value = "letsencrypt"
  }

  command = ["start.sh", "immich"]

  volumes {
    container_path = "/usr/src/app/upload"
    host_path      = "/mnt/raid/immich_data/upload"
  }
  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only = true
  }
  networks_advanced {
    name = "gateway"
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"

   depends_on = [
    docker_container.immich_redis,
    docker_container.immich_db,
    docker_container.immich_typesense
  ]
}
