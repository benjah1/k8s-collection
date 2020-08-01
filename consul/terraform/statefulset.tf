resource "kubernetes_stateful_set" "consul" {
  metadata {
    name      = "consul"
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "consul"
      }
    }

    template {
      metadata {
        labels = {
          app = "consul"
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = ["consul"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }
 
        volume {
          name = "config"

          config_map {
            name = "consul"
          }
        }

        volume {
          name = "tls"

          secret {
            secret_name = "consul"
          }
        }

        container {
          name  = "consul"
          image = "consul:1.7.3"
          args  = ["agent", "-advertise=$(POD_IP)", "-bootstrap-expect=3", "-config-file=/etc/consul/config/server.json", "-encrypt=$(GOSSIP_ENCRYPTION_KEY)"]

          port {
            name           = "ui-port"
            container_port = 8500
          }

          port {
            name           = "alt-port"
            container_port = 8400
          }

          port {
            name           = "udp-port"
            container_port = 53
          }

          port {
            name           = "https-port"
            container_port = 8443
          }

          port {
            name           = "http-port"
            container_port = 8080
          }

          port {
            name           = "serflan"
            container_port = 8301
          }

          port {
            name           = "serfwan"
            container_port = 8302
          }

          port {
            name           = "consuldns"
            container_port = 8600
          }

          port {
            name           = "server"
            container_port = 8300
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
            name = "GOSSIP_ENCRYPTION_KEY"

            value_from {
              secret_key_ref {
                name = "consul"
                key  = "gossip-encryption-key"
              }
            }
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
            mount_path = "/consul/data"
            sub_path_expr = "$(POD_NAME)"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/consul/config"
          }

          volume_mount {
            name       = "tls"
            mount_path = "/etc/tls"
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "consul leave"]
              }
            }
          }
        }

        termination_grace_period_seconds = 10
        service_account_name             = "consul"
        automount_service_account_token = true

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume.consul.metadata.0.labels.pvc
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
 
    service_name          = "consul"
    pod_management_policy = "Parallel"
  }
}

