resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      name = "kafka"
    }
  }
}

resource "kubernetes_network_policy" "kafka_ingress_default_deny" {
  metadata {
    name      = "ingress-default-deny"
    namespace = kubernetes_namespace.kafka.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

module "zk" {
  source = "../../kf-zk/terraform"
  namespace = kubernetes_namespace.kafka.metadata.0.name
}

module "broker" {
  source = "../../kf-broker/terraform"
  namespace = kubernetes_namespace.kafka.metadata.0.name
}

module "schema" {
  source = "../../kf-schema/terraform"
  namespace = kubernetes_namespace.kafka.metadata.0.name
}

module "exporter" {
  source = "../../kf-exporter/terraform"
  namespace = kubernetes_namespace.kafka.metadata.0.name
}
