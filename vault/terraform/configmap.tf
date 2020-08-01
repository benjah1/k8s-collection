resource "kubernetes_config_map" "vault" {
  metadata {
    name      = "vault"
    namespace = var.namespace
  }

  data = {
    "config.hcl" = "${templatefile("${path.module}/configs/config.tmpl", {namespace = var.namespace})}"
  }
}

