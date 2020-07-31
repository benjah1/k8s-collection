resource "kubernetes_network_policy" "es_data_to_es_master" {
  metadata {
    name      = "ingress-es-data-to-es-master"
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
            app = "es-data"
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

      ports {
        port = "9300"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "es_data_to_es_data" {
  metadata {
    name      = "ingress-es-data-to-es-data"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "es-data"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "es-data"
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

      ports {
        port = "9300"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
