resource "kubernetes_deployment" "es_exportor" {
  metadata {
    name      = "es-exportor"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "es-exportor"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-exportor"
        }

        annotations = {
          "prometheus.io/path" = "/metrics"
          "prometheus.io/port" = "9114"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        container {
          name  = "es-exportor"
          image = "justwatch/elasticsearch_exporter:1.1.0"
          args  = ["--es.all", "--es.indices", "--es.uri=http://es-master.monitoring:9200"]

          port {
            name           = "http"
            container_port = 9114
          }

          resources {
            limits {
              cpu    = "100m"
              memory = "128Mi"
            }

            requests {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["sh", "-c", "ps -a | grep elasticsearch_exporter | grep -v grep"]
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

