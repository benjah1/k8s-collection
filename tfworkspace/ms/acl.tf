/* *****
* Manage Consul Token
***** */

resource "consul_acl_policy" "policy-ms-type-a" {
  name = "policy-ms-type-a"
  rules = "key_prefix \"config/ms,type-a\" {policy = \"read\"}"
}

resource "consul_acl_policy" "policy-ms-type-b" {
  name = "policy-ms-type-b"
  rules = "key_prefix \"config/ms,type-b\" {policy = \"read\"}"
}

resource "consul_acl_policy" "policy-ms" {
  name = "policy-ms"
  rules = "key_prefix \"config/ms\" {policy = \"read\"}"
}

resource "consul_acl_role" "ms-type-a" {
  name = "ms-type-a"
  description = "for ms-type-a"

  policies = [
    consul_acl_policy.policy-ms.id,
    consul_acl_policy.policy-ms-type-a.id,
  ]
}

resource "consul_acl_role" "ms-type-b" {
  name = "ms-type-b"
  description = "for ms-type-b"

  policies = [
    consul_acl_policy.policy-ms.id,
    consul_acl_policy.policy-ms-type-b.id
  ]
}

resource "consul_acl_token" "ms-type-a" {
  description = "token for ms-type-a"
  roles = [consul_acl_role.ms-type-a.name]
  local = true
}

resource "consul_acl_token" "ms-type-b" {
  description = "token for ms-type-b"
  roles = [consul_acl_role.ms-type-b.name]
  local = true
}


/* *****
* Manage ms AppRole
***** */
resource "vault_policy" "policy-ms" {
  name = "policy-ms"
  policy = "path \"secret/ms\" {capabilities = [\"read\"]}"
}
resource "vault_policy" "policy-ms-type-a" {
  name = "policy-ms-type-a"
  policy = "path \"secret/ms/type-a\" {capabilities = [\"read\"]}"
}
resource "vault_policy" "policy-ms-type-b" {
  name = "policy-ms-type-b"
  policy = "path \"secret/ms/type-b\" {capabilities = [\"read\"]}"
}
resource "vault_policy" "policy-ms-mysql" {
  name = "policy-ms-mysql"
  policy = "path \"mysql/creds/ms\" {capabilities = [\"create\", \"read\", \"delete\"]}"
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "ms-type-a" {
  backend        = vault_auth_backend.approle.path
  role_name      = "ms-type-a"
  token_policies = [
    vault_policy.policy-ms.name,
    vault_policy.policy-ms-type-a.name,
    vault_policy.policy-ms-mysql.name
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "ms-type-a" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ms-type-a.role_name
}

resource "vault_approle_auth_backend_role" "ms-type-b" {
  backend        = vault_auth_backend.approle.path
  role_name      = "ms-type-b"
  token_policies = [
    vault_policy.policy-ms.name,
    vault_policy.policy-ms-type-b.name,
    vault_policy.policy-ms-mysql.name
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "ms-type-b" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ms-type-b.role_name
}

/* *****
* Manage MySQL Credential
***** */

resource "vault_mount" "mysql" {
  path        = "mysql"
  type        = "database"
}

resource "vault_database_secret_backend_connection" "mysql-ms" {
  backend       = vault_mount.mysql.path
  name          = "messages"
  allowed_roles = ["ms"]

  mysql {
    connection_url  = "root:12345@tcp(192.168.51.103:3306)/"
  }
}

resource "vault_database_secret_backend_role" "role" {
  backend             = vault_mount.mysql.path
  name                = "ms"
  db_name             = vault_database_secret_backend_connection.mysql-ms.name
  default_ttl         = 20
  max_ttl             = 60
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT SELECT,INSERT,CREATE ON messages.* TO '{{name}}'@'%';"
  ]
}
