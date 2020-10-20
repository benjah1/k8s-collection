resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    labels = {
      name = "vault"
    }
  }
}

resource "kubernetes_network_policy" "vault_ingress_default_deny" {
  metadata {
    name      = "ingress-default-deny"
    namespace = kubernetes_namespace.vault.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

module "consul" {
  source = "../../consul/terraform"
  namespace = kubernetes_namespace.vault.metadata.0.name
}

module "vault" {
  source = "../../vault/terraform"
  namespace = kubernetes_namespace.vault.metadata.0.name
  consul_token = module.consul.master_token
}
