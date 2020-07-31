resource "kubernetes_stateful_set" "es_data" {
  metadata {
    name      = "es-data"
    namespace = var.namespace

    labels = {
      app = "es-data"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "es-data"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-data"
        }
      }

      spec {
        init_container {
          name    = "init-chown-data"
          image   = "busybox:1.31.1"
          command = ["chown", "-R", "1000:1000", "/usr/share/elasticsearch/data"]

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
            mount_path = "/usr/share/elasticsearch/data"
            sub_path_expr = "$(POD_NAME)"
          }
        }

        init_container {
          name    = "configure-sysctl"
          image   = "elasticsearch:7.8.0"
          command = ["sysctl", "-w", "vm.max_map_count=262144"]

          security_context {
            privileged = true
          }
        }

        container {
          name  = "es-data"
          image = "elasticsearch:7.8.0"

          port {
            name           = "http"
            container_port = 9200
          }

          port {
            name           = "transport"
            container_port = 9300
          }

          resources {
            limits {
              cpu    = "200m"
              memory = "768Mi"
            }

            requests {
              cpu    = "200m"
              memory = "768Mi"
            }
          }

          env {
            name = "node.name"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "discovery.seed_hosts"
            value = "es-master.monitoring"
          }

          env {
            name  = "cluster.name"
            value = "eslab"
          }

          env {
            name  = "network.host"
            value = "0.0.0.0"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xmx512m -Xms512m"
          }

          env {
            name  = "node.master"
            value = "false"
          }

          env {
            name  = "node.data"
            value = "true"
          }

          env {
            name  = "node.ingest"
            value = "false"
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
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
            sub_path_expr = "$(POD_NAME)"
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "${file("${path.module}/scripts/readiness.sh")}"]
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 3
            failure_threshold     = 3
          }
        }

        termination_grace_period_seconds = 120

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = ["es-data"]
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume.es_data.metadata.0.labels.pvc
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    service_name          = "es-data"
    pod_management_policy = "Parallel"
  }
}
