resource "kubernetes_cluster_role_binding" "filebeat_cluster_role_binding" {
  metadata {
    name = "filebeat-cluster-role-binding"

    labels = {
      app = "filebeat"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "filebeat"
    namespace = "monitoring"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "filebeat-cluster-role"
  }
}

