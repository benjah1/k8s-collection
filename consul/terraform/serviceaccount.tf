resource "kubernetes_service_account" "consul" {
  metadata {
    name      = "consul"
    namespace = var.namespace

    labels = {
      app = "consul"
    }
  }
}

