resource "kubernetes_stateful_set" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

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
          name = "config-dashboard-container"

          config_map {
            name = "grafana-dashboard-container"
          }
        }

        volume {
          name = "config-dashboard-node"

          config_map {
            name = "grafana-dashboard-node"
          }
        }

        init_container {
          name    = "init-chown-data"
          image   = "busybox:1.31.1"
          command = ["chown", "-R", "472:472", "/var/lib/grafana"]

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/grafana"
          }
        }

        container {
          name  = "grafana"
          image = "grafana/grafana:7.0.3"

          port {
            name           = "grafana"
            container_port = 3000
            protocol       = "TCP"
          }

          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "12345"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/grafana/grafana.ini"
            sub_path   = "grafana.ini"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/grafana"
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
            name       = "config-dashboard-container"
            mount_path = "/var/lib/grafana/dashboards/default/container.json"
            sub_path   = "container.json"
          }

          volume_mount {
            name       = "config-dashboard-node"
            mount_path = "/var/lib/grafana/dashboards/default/node.json"
            sub_path   = "node.json"
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = "3000"
            }

            initial_delay_seconds = 60
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

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        selector {
          match_labels = {
            app = "grafana"
          }
        }

        resources {
          requests = {
            storage = "1Gi"
          }
        }

        storage_class_name = "standard"
      }
    }

    service_name = "grafana"
  }
}

