resource "kubernetes_persistent_volume" "pv_prometheus_a" {
  metadata {
    name = "pv-prometheus-a"

    labels = {
      app = "prometheus"
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
        path = "/opt/kind-data/prometheus-a"
        type = "Directory"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv_prometheus_b" {
  metadata {
    name = "pv-prometheus-b"

    labels = {
      app = "prometheus"
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
        path = "/opt/kind-data/prometheus-b"
        type = "Directory"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv_prometheus_c" {
  metadata {
    name = "pv-prometheus-c"

    labels = {
      app = "prometheus"
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
        path = "/opt/kind-data/prometheus-c"
        type = "Directory"
      }
    }
  }
}
