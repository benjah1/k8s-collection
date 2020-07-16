resource "kubernetes_service" "es_kibana" {
  metadata {
    name      = "es-kibana"
    namespace = "monitoring"
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 5601
      target_port = "5601"
    }

    selector = {
      app = "es-kibana"
    }

    cluster_ip = "None"
  }
}

