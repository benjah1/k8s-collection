provider "vault" {
  address = "http://${var.vault_addr}:8200"
  token = var.vault_token
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
