resource "kubernetes_network_policy" "zk_to_zk" {
  metadata {
    name      = "ingress-zk-to-zk"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "zk"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "zk"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "2888"
        protocol = "TCP"
      }

      ports {
        port = "3888"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
