resource "kubernetes_deployment" "ms" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "ms"
        profile = var.profile
      }
    }

    template {
      metadata {
        labels = {
          app = "ms"
          profile = var.profile
        }
      }

      spec {
        image_pull_secrets {
          name = "gitlab-reg"
        }

        container {
          name  = var.name
          image = var.image

          port {
            name           = "http"
            container_port = var.port
          }

          resources {
            limits {
              cpu    = "1000m"
              memory = "1Gi"
            }

            requests {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }

          env {
            name  = "CONSUL_ADDR"
            value = var.consul_addr
          }

          env {
            name  = "CONSUL_TOKEN"
            value = var.consul_token
          }

          env {
            name  = "VAULT_ADDR"
            value = var.vault_addr
          }

          env {
            name  = "VAULT_ROLE_ID"
            value = var.vault_role_id
          }

          env {
            name  = "VAULT_SECRET_ID"
            value = var.vault_secret_id
          }

          env {
            name  = "MS_PROFILE"
            value = var.profile
          }

          env {
            name  = "JAVA_OPTS"
            value = "-Dspring.profiles.active=${var.profile} -Dspring.cloud.vault.mysql.role=ms -Dserver.port=${var.port}"
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = var.port
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

