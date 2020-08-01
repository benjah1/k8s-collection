resource "kubernetes_network_policy" "consul_to_consul" {
  metadata {
    name      = "ingress-consul-to-consul"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "consul"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "consul"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "8300"
        protocol = "TCP"
      }
      ports {
        port = "8301"
        protocol = "TCP"
      }
      ports {
        port = "8302"
        protocol = "TCP"
      }
      ports {
        port = "8301"
        protocol = "UDP"
      }
      ports {
        port = "8302"
        protocol = "UDP"
      }
    }

    policy_types = ["Ingress"]
  }
}
