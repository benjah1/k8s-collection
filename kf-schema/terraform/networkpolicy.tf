resource "kubernetes_network_policy" "schema_to_broker" {
  metadata {
    name      = "ingress-schema-to-broker"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "broker"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "schema"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "9092"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
