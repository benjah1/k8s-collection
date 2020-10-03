resource "consul_key_prefix" "type-a" {
  path_prefix = "config/ms,type-a/"

  subkeys = {
    "feature/toggle/restapi"    = "true"
    "feature/toggle/consumer"   = "false"
  }
}
