resource "kubernetes_service" "es_hq" {
  metadata {
    name      = "es-hq"
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 5000
      target_port = "5000"
    }

    selector = {
      app = "es-hq"
    }

    cluster_ip = "None"
  }
}

