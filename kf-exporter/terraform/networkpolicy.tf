resource "kubernetes_network_policy" "kf_exporter_to_broker" {
  metadata {
    name      = "ingress-kf-exporter-to-broker"
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
            app = "kf-exporter"
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

resource "kubernetes_network_policy" "prometheus_to_kf_exporter" {
  metadata {
    name      = "ingress-prometheus-to-kf-exporter"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "kf-exporter"
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
        port = "8080"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
