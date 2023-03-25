locals {
  dyndns_domain = "cocopapsraspi.duckdns.org"
}

resource "null_resource" "ansible_configuration" {
  triggers = {
    build_dir_sha1 = sha1(join("", [for f in fileset("${path.module}/ansible", "*") : filesha1("${path.module}/ansible/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/ansible"
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_DOMAIN        = local.dyndns_domain
      DYNDNS_TOKEN         = var.dyndns_token
      MOSQUITTO_USER       = var.mosquitto_user
      MOSQUITTO_PASSWORD   = var.mosquitto_password
      WAKER_PC_MAC_ADDRESS = var.gamerpc_mac_address
    }
  }
}
