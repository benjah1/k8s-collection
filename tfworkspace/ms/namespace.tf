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

locals {
  dockercfg = {
    auths = {
      "${var.gitlab_reg_host}" = {
        username = "${var.gitlab_reg_user}"
        password = "${var.gitlab_reg_pass}"
        auth = base64encode("${var.gitlab_reg_user}:${var.gitlab_reg_pass}")
      }
    }
  }
}

resource "kubernetes_secret" "gitlab_reg" {
  metadata {
    name = "gitlab-reg"
    namespace = kubernetes_namespace.ms.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = jsonencode(local.dockercfg)
  }

  type = "kubernetes.io/dockerconfigjson"
}

data "consul_acl_token_secret_id" "ms-type-a" {
  accessor_id = consul_acl_token.ms-type-a.id
}
data "consul_acl_token_secret_id" "ms-type-b" {
  accessor_id = consul_acl_token.ms-type-b.id
}


module "ms-type-a" {
  source = "../../java/terraform-ms"
  namespace = kubernetes_namespace.ms.metadata.0.name
  name = "ms-type-a"
  profile = "type-a"
  replicas = 1
  port = 8080
  image = "${var.gitlab_reg_host}/root/k8s-collection/ms:latest"

  consul_addr = var.consul_addr
  consul_token = data.consul_acl_token_secret_id.ms-type-a.secret_id
  vault_addr = var.vault_addr
  vault_role_id = vault_approle_auth_backend_role.ms-type-a.role_id
  vault_secret_id = vault_approle_auth_backend_role_secret_id.ms-type-a.secret_id

  depends_on = [
    kubernetes_secret.gitlab_reg
  ]
}

module "ms-type-b" {
  source = "../../java/terraform-ms"
  namespace = kubernetes_namespace.ms.metadata.0.name
  name = "ms-type-b"
  profile = "type-b"
  replicas = 1
  port = 8081
  image = "${var.gitlab_reg_host}/root/k8s-collection/ms:latest"

  consul_addr = var.consul_addr
  consul_token = data.consul_acl_token_secret_id.ms-type-b.secret_id
  vault_addr = var.vault_addr
  vault_role_id = vault_approle_auth_backend_role.ms-type-b.role_id
  vault_secret_id = vault_approle_auth_backend_role_secret_id.ms-type-b.secret_id

  depends_on = [
    kubernetes_secret.gitlab_reg
  ]
}
