resource "kubernetes_persistent_volume" "pv_es_data_a" {
  metadata {
    name = "pv-es-data-a"

    labels = {
      app = "es-data"
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
				path = "/opt/kind-data/es-data-a"
				type = "Directory"
			}
		}
  }
}

resource "kubernetes_persistent_volume" "pv_es_data_b" {
  metadata {
    name = "pv-es-data-b"

    labels = {
      app = "es-data"
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
				path = "/opt/kind-data/es-data-b"
				type = "Directory"
			}
		}
  }
}

