terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.19.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}
