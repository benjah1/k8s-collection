resource "kubernetes_service" "vault_standby" {
  metadata {
    name      = "vault-standby"
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      port        = 8200
      target_port = "8200"
    }

    port {
      name        = "https-internal"
      port        = 8201
      target_port = "8201"
    }

    selector = {
      app = "vault"

      vault-active = "false"
    }

    cluster_ip                  = "None"
    publish_not_ready_addresses = true
  }
}

