resource "random_password" "webapp" {
  length           = 18
  special          = true
  override_special = "_%@"
}

resource "random_password" "root" {
  length           = 18
  special          = true
  override_special = "_%@"
}

