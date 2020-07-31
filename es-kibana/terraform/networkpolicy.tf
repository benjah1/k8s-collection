resource "kubernetes_network_policy" "es_kibana_to_es_master" {
  metadata {
    name      = "ingress-es-kibana-to-es-master"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "es-master"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "es-kibana"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "9200"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
