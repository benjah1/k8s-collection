resource "kubernetes_service" "ms" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = var.port
      target_port = var.port
    }

    selector = {
      app = "ms"
      profile = var.profile
    }

    cluster_ip = "None"
  }
}
