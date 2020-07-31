resource "kubernetes_daemonset" "es-filebeat" {
  metadata {
    name      = "es-filebeat"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = "es-filebeat"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-filebeat"
        }
      }

      spec {
        volume {
          name = "filebeat-config"

          config_map {
            name         = "filebeat-config"
            default_mode = "0644"
          }
        }

        volume {
          name = "data"

          host_path {
            path = "/var/lib/filebeat-monitoring-data"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "varlog"

          host_path {
            path = "/var/log"
          }
        }

        container {
          name  = "filebeat"
          image = "elastic/filebeat:7.8.0"
          args  = ["-e", "-E", "http.enabled=true"]

          security_context {
            run_as_user = 0
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

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name       = "filebeat-config"
            read_only  = true
            mount_path = "/usr/share/filebeat/filebeat.yml"
            sub_path   = "filebeat.yml"
          }

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/filebeat/data"
          }

          volume_mount {
            name       = "varlog"
            read_only  = true
            mount_path = "/var/log"
          }

          liveness_probe {
            exec {
              command = ["sh", "-c", "#!/usr/bin/env bash -e\ncurl --fail 127.0.0.1:5066\n"]
            }

            initial_delay_seconds = 20
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "#!/usr/bin/env bash -e\nfilebeat test output\n"]
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
            failure_threshold     = 3
          }
        }

        dns_policy           = "ClusterFirstWithHostNet"
        service_account_name = "es-filebeat"
        host_network         = true
      }
    }
  }
}

