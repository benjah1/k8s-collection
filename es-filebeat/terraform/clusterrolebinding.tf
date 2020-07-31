resource "kubernetes_cluster_role_binding" "filebeat_cluster_role_binding" {
  metadata {
    name = "es-filebeat-cluster-role-binding"

    labels = {
      app = "es-filebeat"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "es-filebeat"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "es-filebeat-cluster-role"
  }
}

