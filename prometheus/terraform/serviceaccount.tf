resource "kubernetes_service_account" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = var.namespace
  }
}
