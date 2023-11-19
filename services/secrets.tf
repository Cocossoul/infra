resource "random_password" "sso_salt" {
  length = 8
}
resource "htpasswd_password" "sso" {
  password = var.sso_password
  salt     = random_password.sso_salt.result
}

resource "random_password" "loki_salt" {
  length = 8
}
resource "random_password" "loki" {
  length  = 16
  special = false
}
resource "htpasswd_password" "loki" {
  password = random_password.loki.result
  salt     = random_password.loki_salt.result
}
