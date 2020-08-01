resource "kubernetes_role" "vault" {
  metadata {
    name = "vault"
    namespace = var.namespace

    labels = {
      app = "vault"
    }
  }

  rule {
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = [""]
    resources  = ["pods"]
  }
}

resource "kubernetes_role_binding" "vault" {
  metadata {
    name = "vault"
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "vault"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "vault"
  }
}

