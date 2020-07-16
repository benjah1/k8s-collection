resource "kubernetes_service" "es_master" {
  metadata {
    name      = "es-master"
    namespace = "monitoring"

    annotations = {
      "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 9200
      target_port = "9200"
    }

    selector = {
      app = "es-master"
    }

    cluster_ip                  = "None"
    publish_not_ready_addresses = true
  }
}

