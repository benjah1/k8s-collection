resource "kubernetes_namespace" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      name = "mysql"
    }
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "mysql"

    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"

          args = ["--default-authentication-plugin=mysql_native_password"]

          port {
            name           = "mysql"
            container_port = 3306
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

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "12345"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/mysql"
            sub_path_expr = "$(POD_NAME)"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume.mysql.metadata.0.labels.pvc
          }
        }

      }
    }
  }
}

