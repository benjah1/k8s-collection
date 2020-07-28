resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name = "data-prometheus"
    namespace = var.namespace
  }

  spec {
    access_modes         = ["ReadWriteMany"]
    storage_class_name   = "standard"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    selector {
      match_labels = {
        app = kubernetes_persistent_volume.prometheus.metadata.0.labels.app
      }
    }
  }

  depends_on = [
    kubernetes_persistent_volume.prometheus
  ]
}
