locals {
    dyndns_domain = "cocopapsvultr.duckdns.org"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.template.yml",
    {
      vultr_ip = vultr_instance.vultr_machine.main_ip
    }
  )
  filename = "${path.module}/inventory.yml"

  provisioner "local-exec" {
    working_dir = path.module
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_DOMAIN = local.dyndns_domain
      DYNDNS_TOKEN  = var.dyndns_token
    }
  }
}
