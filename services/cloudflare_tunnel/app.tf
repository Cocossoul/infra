data "docker_registry_image" "cloudflared" {
  name = "cloudflare/cloudflared:2023.8.2" # renovate_docker
}

resource "docker_image" "cloudflared" {
  name          = data.docker_registry_image.cloudflared.name
  pull_triggers = [data.docker_registry_image.cloudflared.sha256_digest]
}

resource "docker_container" "cloudflared" {
  image = docker_image.cloudflared.image_id
  name  = "cloudflared"

  command = ["tunnel", "--no-autoupdate", "run"]

  env = [
    "TUNNEL_TOKEN=${cloudflare_tunnel.tunnel.tunnel_token}"
  ]

  networks_advanced {
    name = "gateway"
  }

  log_driver = "fluentd"
  log_opts = {
    fluentd-address = "localhost:24224"
    tag = "cloudflared"
  }
  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
