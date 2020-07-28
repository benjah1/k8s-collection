resource "kubernetes_service" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "prometheus"
    }
    cluster_ip = "None"
    port {
      name = "http"
      port        = 9090
      protocol    = "TCP"
      target_port = 9090
    }
  }
}
