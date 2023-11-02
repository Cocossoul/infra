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
      DYNDNS_SUBDOMAIN = var.dyndns_record.name
      DYNDNS_RECORD_ID = var.dyndns_record.id
      DYNDNS_ZONE_ID = var.dyndns_zone.id
      DYNDNS_TOKEN  = var.dyndns_token
    }
  }
}
