terraform {
  backend "s3" {
    bucket         = "cocopaps-terraform-states"
    key            = "infra/services.tf"
    region         = "eu-west-3"
    dynamodb_table = "cocopaps-terraform-locks"
    encrypt        = true
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}
