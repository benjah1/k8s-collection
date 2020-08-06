resource "kubernetes_deployment" "kf_exporter" {
  metadata {
    name      = "kf-exporter"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kf-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "kf-exporter"
        }

        annotations = {
          "prometheus.io/path" = "/metrics"
          "prometheus.io/port" = "8080"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        container {
          name  = "kf-exporter"
          image = "quay.io/google-cloud-tools/kafka-minion:v1.0.0"

          env {
            name    = "TELEMETRY_HOST"
            value   = "0.0.0.0"
          }
          env {
            name    = "TELEMETRY_PORT"
            value   = "8080"
          }
          env {
            name    = "LOG_LEVEL"
            value   = "info"
          }
          env {
            name    = "KAFKA_BROKERS"
            value   = "bootstrap:9092"
          }

          port {
            name           = "http"
            container_port = 8080
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
            http_get {
              path = "/healthcheck"
              port = "http"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
          }

          readiness_probe {
            http_get {
              path = "/readycheck"
              port = "http"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

