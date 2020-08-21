provider "vault" {
  address = "http://localhost:8200"
  token = var.vault_token
}

/* *****
* Manage ms-a Secret
***** */

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


/* *****
* Manage MySQL Credential
***** */

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
  default_ttl         = 20
  max_ttl             = 60
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT SELECT ON messages.* TO '{{name}}'@'%';",
    "GRANT INSERT ON messages.* TO '{{name}}'@'%';"
  ]
}

/* *****
* Manage Consul Token
***** */

resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Manages the Consul backend"

  address = "consul:8500"
  token   = var.consul_token
}

resource "vault_consul_secret_backend_role" "consul-ms-a-type-a" {
  name    = "vault-ms-a-type-a"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    consul_acl_policy.read-policy-ms-a.name,
    consul_acl_policy.read-policy-ms-a-type-a.name,
    consul_acl_policy.read-policy-ms-a-type-b.name
  ]
}

resource "vault_consul_secret_backend_role" "consul-ms-a-type-b" {
  name    = "ms-a-type-b"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    consul_acl_policy.read-policy-ms-a.name,
    consul_acl_policy.read-policy-ms-a-type-b.name
  ]
}

/* *****
* Manage ms-a AppRole
***** */
resource "vault_policy" "read-policy-ms-a" {
  name = "read-policy-ms-a"
  policy = "path \"secret/ms-a\" {capabilities = [\"read\"]}"
}
resource "vault_policy" "read-policy-ms-a-type-a" {
  name = "read-policy-ms-a-type-a"
  policy = "path \"secret/ms-a/type-a\" {capabilities = [\"read\"]}"
}
resource "vault_policy" "read-policy-ms-a-type-b" {
  name = "read-policy-ms-a-type-b"
  policy = "path \"secret/ms-a/type-b\" {capabilities = [\"read\"]}"
}
resource "vault_policy" "write-policy-mysql-ms-a" {
  name = "read-policy-ms-a-type-b"
  policy = "path \"mysql/creds/ms-a\" {capabilities = [\"create\", \"read\", \"delete\"]}"
}


resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "ms-a-type-a" {
  backend        = vault_auth_backend.approle.path
  role_name      = "ms-a-type-a"
  token_policies = [
    vault_policy.read-policy-ms-a.name,
    vault_policy.read-policy-ms-a-type-a.name,
    vault_policy.read-policy-ms-a-type-b.name
  ]
}

resource "vault_approle_auth_backend_role" "ms-a-type-b" {
  backend        = vault_auth_backend.approle.path
  role_name      = "ms-a-type-b"
  token_policies = [
    vault_policy.read-policy-ms-a.name,
    vault_policy.read-policy-ms-a-type-b.name
  ]
}
