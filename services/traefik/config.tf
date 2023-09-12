resource "kubernetes_config_map_v1" "traefik" {
  metadata {
    name = "traefik-config"
  }

  data = {
    "traefik.yml" = "${file("${path.module}/src/traefik.yml")}"
  }
}
