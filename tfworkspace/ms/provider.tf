provider "consul" {
  alias     = "base"
  address   = "${var.consul_addr}:8500"
}

data "consul_key_prefix" "secret" {
  provider  = consul.base

  path_prefix = "secret/"

  subkey {
    name    = "consul_token"
    path    = "consul_token"
  }

  subkey {
    name    = "vault_token"
    path    = "vault_token"
  }
}
