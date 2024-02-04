data "docker_registry_image" "redis" {
  name = "redis:7" # renovate_docker
}

resource "docker_image" "redis" {
  name          = data.docker_registry_image.redis.name
  pull_triggers = [data.docker_registry_image.redis.sha256_digest]
}

resource "docker_container" "redis" {
  image = docker_image.redis.image_id
  name  = "owncloud_redis"
  networks_advanced {
    name = var.gateway
  }
  command = ["--databases", "1"]

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.redis.name
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "redis" {
  name   = "redis_static"
  driver = "local"
}
