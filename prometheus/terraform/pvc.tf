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
        app = "prometheus"
      }
    }
  }
}
