resource "kubernetes_network_policy" "grafana_to_prometheus" {
  metadata {
    name      = "ingress-grafana-to-prometheus"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "prometheus"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "grafana"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "9090"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
