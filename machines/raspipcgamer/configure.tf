locals {
    dyndns_domain = "cocopapsraspi.duckdns.org"
}

resource "null_resource" "ansible_configuration" {
  triggers = {
    build_dir_sha1 = sha1(join("", [for f in fileset("${path.module}", "*") : filesha1("${path.module}/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_DOMAIN = local.dyndns_domain
      DYNDNS_TOKEN  = var.dyndns_token
    }
  }
}
