resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }

  spec {
    port {
      name        = "http"
      port        = 3000
      target_port = "3000"
    }

    selector = {
      app = "grafana"
    }

    cluster_ip = "None"
  }
}

