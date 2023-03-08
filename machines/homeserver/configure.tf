locals {
  dyndns_domain = "cocopapshomeserver.duckdns.org"
}

resource "null_resource" "ansible_configuration" {
  triggers = {
    build_dir_sha1 = sha1(join("", [for f in fileset("${path.module}/ansible", "*") : filesha1("${path.module}/ansible/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/ansible/"
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_DOMAIN = local.dyndns_domain
      DYNDNS_TOKEN  = var.dyndns_token
    }
  }
}
