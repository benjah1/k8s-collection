resource "kubernetes_persistent_volume" "es_data" {
  metadata {
    name = "es-data"

    labels = {
      app = "es-data"
      pvc = "data-es-data"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Recycle"
    storage_class_name               = "standard"

    persistent_volume_source {
      host_path {
        path = "/opt/kind-data"
        type = "Directory"
      }
    }
  }
}
