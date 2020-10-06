provider "mysql" {
  endpoint = "192168.51.103:3306"
  username = "root"
  password = "12345"
}

resource "mysql_database" "messages" {
  name = "messages"
}

resource "null_resource" "messages_table" {

  depends_on = [
    mysql_database.messages
  ]

}
