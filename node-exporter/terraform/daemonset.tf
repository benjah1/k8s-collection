resource "kubernetes_daemonset" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = "node-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "node-exporter"
        }

        annotations = {
          "prometheus.io/path" = "/metrics"
          "prometheus.io/port" = "9100"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        volume {
          name = "proc"

          host_path {
            path = "/proc"
          }
        }

        volume {
          name = "sys"

          host_path {
            path = "/sys"
          }
        }

        container {
          name  = "node-exporter"
          image = "quay.io/prometheus/node-exporter:v1.0.0"
          args  = ["--path.procfs=/host/proc", "--path.sysfs=/host/sys", "--web.listen-address=0.0.0.0:9100"]

          port {
            name           = "metrics"
            container_port = 9100
            host_port = 9100
            protocol       = "TCP"
          }

          env {
            name = "HOST_IP"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "status.hostIP"
              }
            }
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

          volume_mount {
            name       = "proc"
            read_only  = true
            mount_path = "/host/proc"
          }

          volume_mount {
            name       = "sys"
            read_only  = true
            mount_path = "/host/sys"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "9100"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "9100"
            }
          }
        }

        host_network = true
        host_pid     = true
      }
    }
  }
}

