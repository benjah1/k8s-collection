resource "kubernetes_stateful_set" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    service_name = "grafana"

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name = "grafana"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "data-grafana"
          }
        }
 
        init_container {
          name    = "init-chown-data"
          image   = "busybox:1.31.1"
          command = ["chown", "-R", "472:472", "/var/lib/grafana"]

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/grafana"
            sub_path_expr = "$(POD_NAME)"
          }
        }

        container {
          name  = "alpine"
          image = "alpine"
          command = ["tail", "-f", "/dev/null"]
        }

        container {
          name  = "grafana"
          image = "grafana/grafana:7.0.3"

          port {
            name           = "grafana"
            container_port = 3000
            protocol       = "TCP"
          }

          resources {
            limits {
              cpu    = "100m"
              memory = "512Mi"
            }

            requests {
              cpu    = "100m"
              memory = "512Mi"
            }
          }

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "12345"
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }
 
          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/grafana.ini"
            sub_path   = "grafana.ini"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/grafana"
            sub_path_expr = "$(POD_NAME)"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/provisioning/datasources/datasources.yaml"
            sub_path   = "datasources.yaml"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/provisioning/dashboards/dashboards.yaml"
            sub_path   = "dashboards.yaml"
          }

          volume_mount {
            name       = "config"
            mount_path = "/var/lib/grafana/dashboards/default/container.json"
            sub_path   = "container.json"
          }

          volume_mount {
            name       = "config"
            mount_path = "/var/lib/grafana/dashboards/default/node.json"
            sub_path   = "node.json"
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = "3000"
            }

            initial_delay_seconds = 120
            timeout_seconds       = 30
            failure_threshold     = 10
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = "3000"
            }
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }
  }

  depends_on = [
    kubernetes_config_map.grafana,
    kubernetes_service.grafana,
    kubernetes_persistent_volume.pv_grafana,
  ]
}
