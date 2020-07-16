resource "kubernetes_cluster_role" "prometheus" {
  metadata {
    name = "prometheus"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "nodes/metrics", "services", "endpoints", "pods", "ingresses", "configmaps"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses/status", "ingresses"]
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prometheus"
  }
}

