terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  version = "v1.88.2" # renovate_docker_multiple ghcr.io/immich-app/immich-server
}
