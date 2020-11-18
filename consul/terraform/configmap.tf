resource "random_uuid" "token" { }

resource "kubernetes_config_map" "consul" {
  metadata {
    name      = "consul"
    namespace = var.namespace
  }

  data = {
    "server.json" = "${templatefile("${path.module}/configs/server.tmpl", {namespace = var.namespace, token = random_uuid.token.result})}"
  }
}
