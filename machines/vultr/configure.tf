locals {
  dyndns_domain = "cocopapsvultr.duckdns.org"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.template.yml",
    {
      vultr_ip = vultr_instance.vultr_machine.main_ip
    }
  )
  filename = "${path.module}/ansible/inventory.yml"

  provisioner "local-exec" {
    working_dir = "${path.module}/ansible"
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_DOMAIN = var.dyndns_address
      DYNDNS_TOKEN  = var.dyndns_token
    }
  }
}
