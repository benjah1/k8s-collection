provider "consul" {
  address   = "${var.consul_addr}:8500"
  token     = var.consul_token
}

resource "consul_key_prefix" "ms" {
  path_prefix = "config/ms/"

  subkeys = {
    "server/port"                             = "8080"

    "logging/level/root"                      = "INFO"
    "logging/level/org/srpingframework/kafka" = "INFO"
    "logging/level/org/apache/kafka"          = "INFO"

    "spring/kafka/bootstrap-servers"          = "kafka:9092"

    "feature/toggle/restapi"                  = "true"
    "feature/toggle/consumer"                 = "false"

    "spring/datasource/url" = "jdbc:mysql://192.168.51.103:3306/messages?useSSL=false&useUnicode=true&characterEncoding=UTF-8"
  }
}


