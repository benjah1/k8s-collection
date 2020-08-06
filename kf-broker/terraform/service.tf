resource "kubernetes_service" "broker" {
  metadata {
    name = "broker"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "broker"
    }
    cluster_ip = "None"
    port {
      name        = "broker"
      port        = 9092
      protocol    = "TCP"
    }
    publish_not_ready_addresses = true
  }
}

resource "kubernetes_service" "bootstrap" {
  metadata {
    name = "bootstrap"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "broker"
    }
    cluster_ip = "None"
    port {
      name        = "bootstrap"
      port        = 9092
      protocol    = "TCP"
    }
  }
}
