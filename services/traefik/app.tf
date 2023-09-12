terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name = "traefik-deployment"
  }

  spec {
    replicas = 1

    template {
      metadata {
        name = "traefik-replicaset"
      }
      spec {
        volume {
          name = "traefik-config"
          config_map {
            name = "traefik-config"
          }
        }
        container {
          image = "traefik:v2.10.4"
          name  = "traefik-container"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          args = ["--configFile=/config/traefik.yml"]

          env {
            name = "CLOUDFLARE_EMAIL"
            value = "corentin0pape@gmail.com"
          }
          env {
            name = "CLOUDFLARE_API_KEY"
            value = "${var.cloudflare_global_api_key}"
          }
          env {
            name = "KUBECONFIG"
            value = "~/.kube/config"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = 80
            }

            initial_delay_seconds = 10
            period_seconds        = 10
          }

          port {
            name = "insecure"
            container_port = 80
          }

          port {
            name = "secure"
            container_port = 443
          }

          volume_mount {
            name = "traefik-config"
            mount_path = "/config"
            read_only = true
          }
        }
      }
    }
  }
}
