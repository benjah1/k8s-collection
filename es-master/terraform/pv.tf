resource "kubernetes_persistent_volume" "es_master" {
  metadata {
    name = "es-master"

    labels = {
      app = "es-master"
      pvc = "data-es-master"
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
        path = "/opt/kind-data/es-master"
        type = "Directory"
      }
    }
  }
}
