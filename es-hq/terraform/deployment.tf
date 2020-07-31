resource "kubernetes_deployment" "es_hq" {
  metadata {
    name      = "es-hq"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "es-hq"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-hq"
        }
      }

      spec {
        container {
          name  = "es-hq"
          image = "elastichq/elasticsearch-hq:release-v3.5.12"

          port {
            name           = "http"
            container_port = 5000
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
              path = "/"
              port = "5000"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "5000"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

