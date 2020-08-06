resource "kubernetes_service" "zk" {
  metadata {
    name = "zk"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "zk"
    }
    cluster_ip = "None"
    port {
      name = "peer"
      port        = 2888
      protocol    = "TCP"
      target_port = "2888"
    }
    port {
      name = "leader-election"
      port        = 3888
      protocol    = "TCP"
      target_port = "3888"
    }
    publish_not_ready_addresses = true
  }
}

resource "kubernetes_service" "zookeeper" {
  metadata {
    name = "zookeeper"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "zk"
    }
    cluster_ip = "None"
    port {
      name = "client"
      port        = 2181
      protocol    = "TCP"
      target_port = "2181"
    }
  }
}
