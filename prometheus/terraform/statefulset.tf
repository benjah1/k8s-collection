resource "kubernetes_stateful_set" "prometheus" {
  metadata {

    labels = {
      app = "prometheus"
    }

    namespace = var.namespace
    name = "prometheus"
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = 3
    revision_history_limit = 2

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    service_name = "prometheus"

    template {
      metadata {
        labels = {
          app = "prometheus"
        }

        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/path" = "/metrics"
          "prometheus.io/port" = "9090"
        }
      }

      spec {
        service_account_name = "prometheus"
        automount_service_account_token = true

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = ["prometheus"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        init_container {
          name              = "init-chown-data"
          image             = "busybox:1.31.1"
          command           = ["chown", "-R", "65534:65534", "/data"]

          security_context {
            run_as_user = 0
          }

          volume_mount {
            name               = "data"
            mount_propagation = "None"
            mount_path         = "/data"
          }
        }

        container {
          name              = "prometheus"
          image             = "prom/prometheus:v2.19.1"

          args = [
            "--config.file=/etc/config/prometheus.yml",
            "--storage.tsdb.path=/data",
            "--storage.tsdb.retention.time=7d",
            "--web.console.libraries=/etc/prometheus/console_libraries",
            "--web.console.templates=/etc/prometheus/consoles",
            "--web.enable-lifecycle",
          ]

          port {
            container_port = 9090
          }

          resources {
            limits {
              cpu    = "200m"
              memory = "1000Mi"
            }

            requests {
              cpu    = "200m"
              memory = "1000Mi"
            }
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config"
            mount_propagation   = "None"
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
            mount_propagation   = "None"
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          liveness_probe {
            http_get {
              path   = "/-/healthy"
              port   = 9090
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        termination_grace_period_seconds = 60

        volume {
          name = "config-volume"

          config_map {
            name = "prometheus"
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes         = ["ReadWriteOnce"]
        storage_class_name   = "standard"
        resources {
          requests = {
            storage = "5Gi"
          }
        }
        selector {
          match_labels = {
            app = "prometheus"
          }
        }
      }
    }
  }
}
