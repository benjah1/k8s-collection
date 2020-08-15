provider "consul" {
  address    = "localhost:8500"
}

resource "consul_key_prefix" "ms-a" {
  path_prefix = "config/ms-a/"

  subkeys = {
    "logging/level/root"                      = "INFO"
    "logging/level/org/srpingframework/kafka" = "INFO"
    "logging/level/org/apache/kafka"          = "INFO"

    "spring/kafka/bootstrap-servers"          = "kafka:9092"
  }
}


provider "vault" {
  address = "http://localhost:8200"
  token = "s.wKwep8VyxvEcFvVAoC6vvoLY"
}

resource "vault_mount" "secret" {
  path        = "secret"
  type        = "kv"
}

resource "vault_generic_secret" "ms-a" {
  path = "secret/ms-a"

  data_json = <<EOT
{
  "spring": {
    "kafka": {
      "topic": "test"
    }
  }
}
EOT

  depends_on = [
    vault_mount.secret
  ]
}

resource "vault_mount" "mysql" {
  path        = "mysql"
  type        = "database"
}

resource "vault_database_secret_backend_connection" "mysql-ms-a" {
  backend       = vault_mount.mysql.path
  name          = "messages"
  allowed_roles = ["ms-a"]

  mysql {
    connection_url  = "root:12345@tcp(mysql:3306)/"
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = vault_mount.mysql.path
  name                = "ms-a"
  db_name             = vault_database_secret_backend_connection.mysql-ms-a.name
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT SELECT ON messages.* TO '{{name}}'@'%';",
    "GRANT INSERT ON messages.* TO '{{name}}'@'%';"
  ]
}
