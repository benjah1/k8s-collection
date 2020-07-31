resource "kubernetes_network_policy" "es_filebeat_to_es_master" {
  metadata {
    name      = "ingress-es-filebeat-to-es-master"
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
            app = "es-filebeat"
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
