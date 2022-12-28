resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.template.yml",
    {
      dyndns_address = var.dyndns_address
    }
  )
  filename = "${path.module}/ansible/inventory.yml"
}

resource "null_resource" "ansible_configuration" {
  triggers = {
    build_dir_sha1 = sha1(join("", [for f in fileset("${path.module}/ansible", "*") : filesha1("${path.module}/ansible/${f}")]))
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/ansible/"
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_DOMAIN = var.dyndns_address
      DYNDNS_TOKEN  = var.dyndns_token
    }
  }
}
