resource "kubernetes_persistent_volume_claim" "grafana" {
  metadata {
    name = "data-grafana"
    namespace = var.namespace
  }

  spec {
    access_modes         = ["ReadWriteMany"]
    storage_class_name   = "standard"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    selector {
      match_labels = {
        app = "grafana"
      }
    }
  }
}
