resource "kubernetes_stateful_set" "zk" {
  metadata {
    name = "zk"
    namespace = var.namespace
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = var.replicas
    revision_history_limit = 2

    selector {
      match_labels = {
        app = "zk"
      }
    }

    service_name = "zk"

    template {
      metadata {
        labels = {
          app = "zk"
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
                  values = ["zk"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        container {
          name              = "zk"
          image             = "confluentinc/cp-zookeeper:5.5.1"

          command = [
            "bash",
            "-c",
            "ZOOKEEPER_SERVER_ID=$(($${POD_NAME##*-}+1)) /etc/confluent/docker/run"
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
            name = "ZOOKEEPER_CLIENT_PORT"
            value = "2181"
          }

          env {
            name = "ZOOKEEPER_TICK_TIME"
            value = "2000"
          }

          env {
            name = "ZOOKEEPER_INIT_LIMIT"
            value = "5"
          }

          env {
            name = "ZOOKEEPER_SYNC_LIMIT"
            value = "2"
          }

          env {
            name  = "ZOOKEEPER_SERVERS"
            value = "zk-0.zk:2888:3888;zk-1.zk:2888:3888;zk-2.zk:2888:3888"
          }

          env {
            name  = "KAFKA_OPTS"
            value = "-Dzookeeper.4lw.commands.whitelist=ruok"
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["sh", "-ce", "kill -s TERM 1; while $(kill -0 1 2>/dev/null); do sleep 1; done"]
              }
            }
          }

          port {
            name = "client"
            container_port = 2181
          }

          port {
            name = "peer"
            container_port = 2888
          }

          port {
            name = "leader-election"
            container_port = 3888
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
            exec {
              command = [
                "/bin/sh",
                "-c",
                "[ \"imok\" = \"$(echo ruok | nc -w 1 -q 1 127.0.0.1 2181)\" ]"
              ]
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/zookeeper"
            sub_path_expr = "$(POD_NAME)"
          }
        }

        termination_grace_period_seconds = 10

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume.zk.metadata.0.labels.pvc
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
    kubernetes_service.zk,
    kubernetes_persistent_volume.zk,
  ]
}
