resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = var.namespace

    labels = {
      app = "vault"
    }
  }
}

