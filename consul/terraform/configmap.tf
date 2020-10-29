locals {
  triggers = {
    cluster_pv_id = kubernetes_persistent_volume.consul.id
  }


  token = uuid()
}

resource "kubernetes_config_map" "consul" {
  metadata {
    name      = "consul"
    namespace = var.namespace
  }

  data = {
    "server.json" = "${templatefile("${path.module}/configs/server.tmpl", {namespace = var.namespace, token = local.token})}"
  }
}
