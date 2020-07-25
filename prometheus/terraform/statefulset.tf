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
    replicas               = var.replicas
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
            name               = "data"
            mount_path         = "/data"
            sub_path_expr = "$(POD_NAME)"
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

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

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
            sub_path_expr = "$(POD_NAME)"
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

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "data-prometheus"
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
  }

/*
  provisioner "local-exec" {
    command = "kubectl -n ${var.namespace} patch sts prometheus --patch \"$(cat ${path.module}/patch/subpathexpr.yaml)\""
  }
*/
}
