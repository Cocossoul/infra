resource "random_password" "monitoring_admin_salt" {
  length = 8
}

resource "htpasswd_password" "monitoring_admin" {
  password = var.monitoring_admin_password
  salt     = random_password.monitoring_admin_salt.result
}

resource "random_password" "elasticsearch_salt" {
  length = 8
}
resource "random_password" "elasticsearch" {
  length = 16
  special = false
}
resource "htpasswd_password" "elasticsearch" {
  password = random_password.elasticsearch.result
  salt     = random_password.elasticsearch_salt.result
}
