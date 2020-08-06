resource "kubernetes_service" "schema" {
  metadata {
    name      = "schema"
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8081
      target_port = "8081"
    }

    selector = {
      app = "schema"
    }

    cluster_ip = "None"
  }
}

