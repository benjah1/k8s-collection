resource "kubernetes_service_account" "es-filebeat" {
  metadata {
    name      = "es-filebeat"
    namespace = var.namespace

    labels = {
      app = "es-filebeat"
    }
  }
}

