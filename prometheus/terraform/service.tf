resource "kubernetes_service" "prometheus" {
  metadata {
    name = "prometheus"
		namespace = var.namespace
  }
  spec {
    selector = {
      app = "${kubernetes_stateful_set.prometheus.spec.0.template.0.metadata.0.labels.app}"
    }
    cluster_ip = "None"
    port {
			name = "http"
      port        = 8080
			protocol    = "TCP"
      target_port = 80
    }
  }
}
