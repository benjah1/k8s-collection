resource "kubernetes_network_policy" "broker_to_broker" {
  metadata {
    name      = "ingress-broker-to-broker"
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
            app = "broker"
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

resource "kubernetes_network_policy" "broker_to_zk" {
  metadata {
    name      = "ingress-broker-to-zk"
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
            app = "broker"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "2181"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
