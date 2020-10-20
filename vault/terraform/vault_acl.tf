provider "vault" {
  address = "http://${var.vault_addr}:8200"
  token = data.external.vault_init.root_token
}


