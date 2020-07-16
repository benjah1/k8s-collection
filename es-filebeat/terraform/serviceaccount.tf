resource "kubernetes_service_account" "filebeat" {
  metadata {
    name      = "filebeat"
    namespace = "monitoring"

    labels = {
      app = "filebeat"
    }
  }
}

