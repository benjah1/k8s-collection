resource "kubernetes_service" "node_exporter" {
  metadata {
    name      = "node-exporter"
    namespace = "monitoring"
  }

  spec {
    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 9100
      target_port = "9100"
    }

    selector = {
      app = "node-exporter"
    }

    type = "ClusterIP"
  }
}

