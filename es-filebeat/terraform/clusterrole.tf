resource "kubernetes_cluster_role" "filebeat_cluster_role" {
  metadata {
    name = "filebeat-cluster-role"

    labels = {
      app = "filebeat"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces", "nodes", "pods"]
  }
}

