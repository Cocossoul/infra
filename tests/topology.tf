terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.12.0"
    }
  }
}

# Configure the Vultr Provider
provider "vultr" {
  rate_limit = 100
  retry_limit = 3
}

resource "vultr_instance" "test_home_server" {
    plan = "vc2-1c-1gb"
    region = "cdg"
    os_id = 1743
    label = "test_home_server"
    hostname = "test-home-server"
    enable_ipv6 = false
    activation_email = false
    ssh_key_ids = [ "60f8f596-14d5-4d06-a662-51ce92f4adf3" ]
    script_id = vultr_startup_script.test_home_server_startup_script.id
}

resource "vultr_startup_script" "test_home_server_startup_script" {
    name = "home-server-startup-script"
    type = "boot"
    script = filebase64("home_server_startup_script.sh")
}

resource "local_file" "ansible_inventory" {
  content = templatefile("test-inventory.yml.tmpl",
    {
        test_home_server_ip = vultr_instance.test_home_server.main_ip
    }
  )
  filename = "inventory.yml"
}
