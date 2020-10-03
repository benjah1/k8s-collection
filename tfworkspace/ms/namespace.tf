provider "kubernetes" {
  config_context   = "kind-kind"
}

resource "kubernetes_namespace" "ms" {
  metadata {
    name = "ms"
    labels = {
      name = "ms"
    }
  }
}

resource "kubernetes_network_policy" "monitoring_ingress_default_deny" {
  metadata {
    name      = "ingress-default-deny"
    namespace = kubernetes_namespace.ms.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

module "ms-type-a" {
  source = "../../java/terraform-ms"
  namespace = kubernetes_namespace.ms.metadata.0.name
  name = "ms-type-a"
  profile = "type-a"
  replicas = 1
  image = "192.168.0.76:38081/root/k8s-collection/ms:latest"

  consul_addr = var.consul_addr
  consul_token = consul_acl_token.ms-type-a.id
  vault_addr = var.vault_addr
  vault_role_id = vault_approle_auth_backend_role.ms-type-a.role_id
  vault_secret_id = ""
}

module "ms-type-b" {
  source = "../../java/terraform-ms"
  namespace = kubernetes_namespace.ms.metadata.0.name
  name = "ms-type-b"
  profile = "type-b"
  replicas = 1
  image = "192.168.0.76:38081/root/k8s-collection/ms:latest"

  consul_addr = var.consul_addr
  consul_token = consul_acl_token.ms-type-b.id
  vault_addr = var.vault_addr
  vault_role_id = vault_approle_auth_backend_role.ms-type-b.role_id
  vault_secret_id = ""
}
