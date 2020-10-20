provider "consul" {
  address   = "${var.consul_addr}:8500"
  token     = var.consul_token
}

resource "consul_key_prefix" "ms" {
  path_prefix = "config/ms/"

  subkeys = {
    "logging/level/root"                      = "INFO"
    "logging/level/org/srpingframework/kafka" = "INFO"
    "logging/level/org/apache/kafka"          = "INFO"

    "spring/kafka/bootstrap-servers"          = "${var.kafka_bootstrap_server}"

    "feature/toggle/restapi"                  = "true"
    "feature/toggle/consumer"                 = "false"

    "spring/datasource/url" = "jdbc:mysql://${var.mysql_addr}/messages?useSSL=false&useUnicode=true&characterEncoding=UTF-8"
    "spring/datasource/initialization-mode" = "always"
  }
}


