resource "kubernetes_deployment" "es_kibana" {
  metadata {
    name      = "es-kibana"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "es-kibana"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-kibana"
        }
      }

      spec {
        container {
          name  = "es-kibana"
          image = "kibana:7.8.0"

          port {
            name           = "http"
            container_port = 5601
          }

          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "http://es-master.monitoring:9200"
          }

          env {
            name  = "SERVER_HOST"
            value = "0.0.0.0"
          }

          env {
            name  = "NODE_OPTIONS"
            value = "--max-old-space-size=1800"
          }

          readiness_probe {
            http_get {
              path = "/app/kibana"
              port = "5601"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

