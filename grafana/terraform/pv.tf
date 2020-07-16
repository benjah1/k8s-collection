resource "kubernetes_persistent_volume" "pv_grafana" {
  metadata {
    name = "pv-grafana"

    labels = {
      app = "grafana"
    }
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Recycle"
    storage_class_name               = "standard"

    persistent_volume_source {
      host_path {
        path = "/opt/kind-data/grafana-a"
        type = "Directory"
      }
    }
  }
}
