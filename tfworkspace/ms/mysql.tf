provider "mysql" {
  endpoint = var.mysql_addr
  username = var.mysql_user
  password = var.mysql_pass
}

resource "mysql_database" "messages" {
  name = "messages"
}
