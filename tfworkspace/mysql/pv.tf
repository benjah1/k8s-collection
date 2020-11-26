resource "kubernetes_persistent_volume" "mysql" {
  metadata {
    name = "mysql"

    labels = {
      app = "mysql"
      pvc = "data-mysql"
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
        path = "/opt/kind-data/mysql/"
        type = "Directory"
      }
    }
  }
}
