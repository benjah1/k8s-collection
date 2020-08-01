resource "kubernetes_cluster_role" "consul" {
  metadata {
    name = "consul"

    labels = {
      app = "consul"
    }
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["pods"]
  }
}

resource "kubernetes_cluster_role_binding" "consul" {
  metadata {
    name = "consul"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "consul"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "consul"
  }
}

