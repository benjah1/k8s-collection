resource "kubernetes_network_policy" "es-exportor" {
  metadata {
    name      = "ingress-es-exportor"
    namespace = "monitoring"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "es-exportor"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "prometheus"
          }
        }  

        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
      }

      ports {
        port = "9114"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
