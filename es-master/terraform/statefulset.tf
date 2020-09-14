resource "kubernetes_stateful_set" "es_master" {
  metadata {
    name      = "es-master"
    namespace = var.namespace

    labels = {
      app = "es-master"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "es-master"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-master"
        }
      }

      spec {
        init_container {
          name    = "init-chown-data"
          image   = var.image_busybox
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
          image   = var.image_elasticsearch
          command = ["sysctl", "-w", "vm.max_map_count=262144"]

          security_context {
            privileged = true
          }
        }

        container {
          name  = "es-master"
          image = var.image_elasticsearch

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
              cpu    = var.resource_cpu
              memory = var.resource_memory
            }

            requests {
              cpu    = var.resource_cpu
              memory = var.resource_memory
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
            name  = "cluster.initial_master_nodes"
            value = "es-master-0,es-master-1,es-master-2"
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
            value = var.heap_size
          }

          env {
            name  = "node.master"
            value = "true"
          }

          env {
            name  = "node.data"
            value = "false"
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

        container {
          name    = "elasticsearch-master-graceful-termination-handler"
          image   = var.image_elasticsearch
          command = ["sh", "-c", "${file("${path.module}/scripts/termination.sh")}"]

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
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
                  values = ["es-master"]
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume.es_master.metadata.0.labels.pvc
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    service_name          = "es-master"
    pod_management_policy = "Parallel"
  }
}

