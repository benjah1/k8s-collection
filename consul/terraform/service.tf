resource "kubernetes_service" "consul" {
  metadata {
    name      = "consul"
    namespace = var.namespace

    labels = {
      name = "consul"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8500
      target_port = "8500"
    }

    port {
      name        = "https"
      port        = 8443
      target_port = "8443"
    }

    port {
      name        = "rpc"
      port        = 8400
      target_port = "8400"
    }

    port {
      name        = "serflan-tcp"
      protocol    = "TCP"
      port        = 8301
      target_port = "8301"
    }

    port {
      name        = "serflan-udp"
      protocol    = "UDP"
      port        = 8301
      target_port = "8301"
    }

    port {
      name        = "serfwan-tcp"
      protocol    = "TCP"
      port        = 8302
      target_port = "8302"
    }

    port {
      name        = "serfwan-udp"
      protocol    = "UDP"
      port        = 8302
      target_port = "8302"
    }

    port {
      name        = "server"
      port        = 8300
      target_port = "8300"
    }

    port {
      name        = "consuldns"
      port        = 8600
      target_port = "8600"
    }

    selector = {
      app = "consul"
    }

    cluster_ip = "None"
  }
}

