resource "kubernetes_deployment" "schema" {
  metadata {
    name      = "schema"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "schema"
      }
    }

    template {
      metadata {
        labels = {
          app = "schema"
        }
      }

      spec {
        container {
          name  = "schema"
          image = "confluentinc/cp-schema-registry:5.5.1"

          port {
            name           = "http"
            container_port = 8081
          }

          resources {
            limits {
              cpu    = "100m"
              memory = "256M"
            }

            requests {
              cpu    = "100m"
              memory = "256M"
            }
          }

          env {
            name = "SCHEMA_REGISTRY_HOST_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "status.podIP"
              }
            }
          }

          env {
            name  = "SCHEMA_REGISTRY_LISTENERS"
            value = "http://0.0.0.0:8081"
          }
          env {
            name  = "SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS"
            value = "bootstrap:9092"
          }
          env {
            name  = "SCHEMA_REGISTRY_KAFKASTORE_GROUP_ID"
            value = "schema-registry"
          }
          env {
            name  = "SCHEMA_REGISTRY_MASTER_ELIGIBILITY"
            value = "true"
          }
          env {
            name  = "SCHEMA_REGISTRY_HEAP_OPTS"
            value = "-Xms128M -Xmx129M"
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "8081"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

