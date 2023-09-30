locals {
    fail2ban_cloudflare_action = base64encode(templatefile("${path.module}/src/fail2ban_cloudflare.template.action",
    {
      cloudflare_global_api_key = var.cloudflare_global_api_key
    }
  ))
}
