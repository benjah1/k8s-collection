resource "kubernetes_service" "prometheus" {
  metadata {
    name = "prometheus"
		namespace = var.namespace
  }
  spec {
    selector = {
      app = "${kubernetes_stateful_set.prometheus.spec.template.metadata.0.labels.app}"
    }
    client_ip = "None"
    port {
			name = "http"
      port        = 8080
			protocol    = "TCP"
      target_port = 80
    }
  }
}
