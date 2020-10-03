provider "consul" {
  address     = "localhost:8500"
  token       = var.consul_token
}

resource "consul_key_prefix" "ms-a" {
  path_prefix = "config/ms-a/"

  subkeys = {
    "server/port"                             = "8080"

    "logging/level/root"                      = "INFO"
    "logging/level/org/srpingframework/kafka" = "INFO"
    "logging/level/org/apache/kafka"          = "INFO"

    "spring/kafka/bootstrap-servers"          = "kafka:9092"

    "feature/toggle/restapi"                  = "true"
    "feature/toggle/consumer"                 = "false"

    "spring/datasource/url" = "jdbc:mysql://mysql:3306/messages?useSSL=false&useUnicode=true&characterEncoding=UTF-8"
  }
}

resource "consul_key_prefix" "type-a" {
  path_prefix = "config/ms-a,type-a/"

  subkeys = {
    "feature/toggle/restapi"                  = "true"
    "feature/toggle/consumer"                 = "false"
  }
}

resource "consul_key_prefix" "type-b" {
  path_prefix = "config/ms-a,type-b/"

  subkeys = {
    "logging/level/root"                      = "INFO"
    "server/port"                             = "8081"
    "feature/toggle/restapi"                  = "false"
    "feature/toggle/consumer"                 = "true"
  }
}

resource "consul_acl_policy" "read-policy-ms-a" {
  name = "read-policy-ms-a"
  rules = "key_prefix \"config/ms-a\" {policy = \"read\"}"
}
resource "consul_acl_policy" "read-policy-ms-a-type-a" {
  name = "read-policy-ms-a-type-a"
  rules = "key_prefix \"config/ms-a,type-a\" {policy = \"read\"}"
}
resource "consul_acl_policy" "read-policy-ms-a-type-b" {
  name = "read-policy-ms-a-type-b"
  rules = "key_prefix \"config/ms-a,type-b\" {policy = \"read\"}"
}

resource "consul_acl_role" "read-ms-a-type-a" {
  name = "ms-a-type-a"
  description = "for ms-a-type-a"

  policies = [
    consul_acl_policy.read-policy-ms-a.id,
    consul_acl_policy.read-policy-ms-a-type-a.id,
    consul_acl_policy.read-policy-ms-a-type-b.id
  ]
}

resource "consul_acl_role" "read-ms-a-type-b" {
  name = "ms-a-type-b"
  description = "for ms-a-type-b"

  policies = [
    consul_acl_policy.read-policy-ms-a.id,
    consul_acl_policy.read-policy-ms-a-type-b.id
  ]
}
