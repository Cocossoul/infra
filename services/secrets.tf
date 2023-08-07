resource "random_password" "monitoring_admin_salt" {
  length = 8
}

resource "htpasswd_password" "monitoring_admin" {
  password = var.monitoring_admin_password
  salt     = random_password.monitoring_admin_salt.result
}
