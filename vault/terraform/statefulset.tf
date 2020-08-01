resource "kubernetes_stateful_set" "vault" {
  metadata {
    name      = "vault"
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "vault"
      }
    }

    template {
      metadata {
        labels = {
          app = "vault"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name = "vault"

            items {
              key  = "config.hcl"
              path = "config.hcl"
            }
          }
        }

        container {
          name    = "vault"
          image   = "vault:1.4.2"
          command = ["vault", "server", "-config=/home/vault/config/config.hcl"]

          port {
            name           = "http"
            container_port = 8200
          }

          port {
            name           = "https-internal"
            container_port = 8201
          }

          port {
            name           = "http-rep"
            container_port = 8202
          }

          env {
            name = "HOST_IP"

            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name = "VAULT_K8S_POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "VAULT_K8S_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "VAULT_ADDR"
            value = "http://127.0.0.1:8200"
          }

          env {
            name  = "VAULT_API_ADDR"
            value = "http://$(POD_IP):8200"
          }

          env {
            name  = "SKIP_CHOWN"
            value = "true"
          }

          env {
            name  = "SKIP_SETCAP"
            value = "true"
          }

          env {
            name = "HOSTNAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "VAULT_CLUSTER_ADDR"
            value = "https://$(HOSTNAME).vault-internal:8201"
          }

          env {
            name = "VAULT_RAFT_NODE_ID"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/home/vault/config"
          }

          liveness_probe {
            http_get {
              path   = "/v1/sys/health?standbyok=true"
              port   = "8200"
              scheme = "HTTP"
            }

            initial_delay_seconds = 300
            timeout_seconds       = 5
            period_seconds        = 3
            success_threshold     = 1
          }

          readiness_probe {
            exec {
              command = ["/bin/sh", "-ec", "vault status -tls-skip-verify"]
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 3
            success_threshold     = 1
            failure_threshold     = 2
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "sleep 5 && kill -SIGTERM $(pidof vault)"]
              }
            }
          }
        }

        termination_grace_period_seconds = 10
        service_account_name             = "vault"
        automount_service_account_token = true

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = ["vault"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }

    service_name          = "vault-internal"
    pod_management_policy = "Parallel"

    update_strategy {
      type = "OnDelete"
    }
  }
}

