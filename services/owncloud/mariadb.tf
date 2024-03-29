resource "docker_container" "owncloud_db" {
  image = var.mariadb_image.image_id
  name  = "owncloud_db"

  env = [
    "MYSQL_RANDOM_ROOT_PASSWORD=\"true\"",
    "MYSQL_DATABASE=owncloud",
    "MYSQL_USER=owncloud",
    "MYSQL_PASSWORD=${var.owncloud_db_password}"
  ]

  command = ["--max-allowed-packet=128M", "--innodb-log-file-size=64M"]

  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-u", "root", "--password=owncloud"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }

  volumes {
    container_path = "/var/lib/mysql"
    host_path      = "/mnt/raid/owncloud_data/owncloud_db"
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
