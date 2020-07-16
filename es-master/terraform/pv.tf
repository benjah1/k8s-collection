resource "kubernetes_persistent_volume" "pv_es_master_a" {
  metadata {
    name = "pv-es-master-a"

    labels = {
      app = "es-master"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Recycle"
    storage_class_name               = "standard"

    persistent_volume_source {
      host_path {
        path = "/opt/kind-data/es-master-a"
        type = "Directory"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv_es_master_b" {
  metadata {
    name = "pv-es-master-b"

    labels = {
      app = "es-master"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Recycle"
    storage_class_name               = "standard"

    persistent_volume_source {
      host_path {
        path = "/opt/kind-data/es-master-b"
        type = "Directory"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "pv_es_master_c" {
  metadata {
    name = "pv-es-master-c"

    labels = {
      app = "es-master"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Recycle"
    storage_class_name               = "standard"

    persistent_volume_source {
      host_path {
        path = "/opt/kind-data/es-master-c"
        type = "Directory"
      }
    }
  }
}
