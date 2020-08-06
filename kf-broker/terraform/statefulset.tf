resource "kubernetes_stateful_set" "broker" {
  metadata {
    name = "broker"
    namespace = var.namespace
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = var.replicas
    revision_history_limit = 2

    selector {
      match_labels = {
        app = "broker"
      }
    }

    service_name = "broker"

    template {
      metadata {
        labels = {
          app = "broker"
        }
      }

      spec {
        security_context {
          fs_group = 65534
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = ["broker"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        container {
          name              = "broker"
          image             = "confluentinc/cp-kafka:5.5.1"

          command = [
            "bash",
            "-c",
            "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://$${HOSTNAME}.broker:9092 KAFKA_BROKER_ID=$(($${POD_NAME##*-}+1)) /etc/confluent/docker/run"
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

          env {
            name = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zk-0.zk:2181,zk-1.zk:2181,zk-2.zk:2181"
          }

          env {
            name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT"
          }

          env {
            name = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://0.0.0.0:9094,PLAINTEXT_HOST://localhost:9092"
          }

          env {
            name  = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = "1"
          }

          env {
            name  = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS"
            value = "0"
          }

          env {
            name  = "KAFKA_JMX_PORT"
            value = "9101"
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-ce", "kill -s TERM 1; while $(kill -0 1 2>/dev/null); do sleep 1; done"]
              }
            }
          }

          port {
            name = "broker"
            container_port = 9092
          }

          port {
            name = "jmx"
            container_port = 9101
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "1000Mi"
            }

            requests {
              cpu    = "500m"
              memory = "1000Mi"
            }
          }

          readiness_probe {
            tcp_socket {
              port = 9092
            }
            initial_delay_seconds = 30
            timeout_seconds       = 1
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/kafka"
            sub_path_expr = "$(POD_NAME)"
          }
        }

        termination_grace_period_seconds = 30

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume.broker.metadata.0.labels.pvc
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

  depends_on = [
    kubernetes_service.broker,
    kubernetes_persistent_volume.broker,
  ]
}
