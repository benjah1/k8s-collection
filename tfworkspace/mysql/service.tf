resource "kubernetes_service" "consul" {
  metadata {
    name      = "mysql"
    namespace = var.namespace

    labels = {
      name = "mysql"
    }
  }

  spec {
    port {
      name        = "mysql"
      port        = 3306
      target_port = "3306"
    }
  }
}
