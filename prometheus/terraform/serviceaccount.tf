resource "kubernetes_service_account" "prometheus-sa" {
  metadata {
    name = "prometheus"
		namespace = var.namespace
  }
}
