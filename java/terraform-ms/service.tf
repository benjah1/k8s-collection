resource "kubernetes_service" "ms" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "ms"
      profile = var.profile
    }

    cluster_ip = "None"
  }
}
