provider "kubernetes" {
  config_path = "${path.root}/vultr_k3s.config"
  alias       = "vultr_machine"
}


module "vultr_traefik" {
  source = "./traefik"
  cloudflare_global_api_key = var.cloudflare_global_api_key
  providers = {
    kubernetes = kubernetes.vultr_machine
  }
}
