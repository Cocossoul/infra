data "docker_registry_image" "fail2ban" {
  name = "crazymax/fail2ban:1.0.2" # renovate_docker
}

resource "docker_image" "fail2ban" {
  name          = data.docker_registry_image.fail2ban.name
  pull_triggers = [data.docker_registry_image.fail2ban.sha256_digest]
}

resource "docker_container" "fail2ban" {
  image = docker_image.fail2ban.image_id
  name  = "fail2ban"

  env = [
      "F2B_DB_PURGE_AGE=14d"
  ]

  upload {
    file = "/data/jail.d/treafik.conf"
    source = "${path.module}/src/fail2ban.conf"
    source_hash = filesha256("${path.module}/src/fail2ban.conf")
  }

  upload {
    file = "/data/filter.d/traefik-basic-auth.conf"
    source = "${path.module}/src/fail2ban_filter_auth.conf"
    source_hash = filesha256("${path.module}/src/fail2ban_filter_auth.conf")
  }

  upload {
    file = "/etc/fail2ban/action.d/cloudflare.conf"
    content_base64 = base64encode(local.fail2ban_cloudflare_action)
  }

  volumes {
    container_path = "/var/log/traefik"
    volume_name    = docker_volume.reverse-proxy_logs.name
    read_only = true
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.fail2ban.name
  }

  network_mode = "host"

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "fail2ban" {
  name   = "fail2ban_static"
  driver = "local"
}
