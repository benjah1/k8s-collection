resource "kubernetes_network_policy" "vault_to_consul" {
  metadata {
    name      = "ingress-vault-to-consul"
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
            app = "vault"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "8500"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "vault_to_vault" {
  metadata {
    name      = "ingress-vault-to-vault"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "vault"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "vault"
          }
        }  

        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }

      ports {
        port = "8201"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
