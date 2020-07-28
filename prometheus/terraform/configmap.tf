resource "kubernetes_config_map" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = var.namespace
  }

  data = {
    "prometheus.yml" = "${file("${path.module}/config/prometheus.yml")}"
  }
}
