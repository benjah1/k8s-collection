resource "kubernetes_config_map" "filebeat_config" {
  metadata {
    name      = "filebeat-config"
    namespace = var.namespace

    labels = {
      app = "filebeat"
    }
  }

  data = {
    "filebeat.yml" = "${file("${path.module}/config/filebeat.yml")}"
  }
}

