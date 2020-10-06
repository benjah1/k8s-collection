resource "consul_key_prefix" "type-b" {
  path_prefix = "config/ms,type-b/"

  subkeys = {
    "logging/level/root"        = "INFO"
    "feature/toggle/restapi"    = "false"
    "feature/toggle/consumer"   = "true"
  }
}
