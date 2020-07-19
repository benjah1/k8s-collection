resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

module "prometheus" {
  source = "../prometheus/terraform"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  replicas = 3
}

module "node-exporter" {
  source = "../node-exporter/terraform"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
}

module "grafana" {
  source = "../grafana/terraform"
  namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
}


module "es-master" {
  source = "../es-master/terraform"
}

module "es-data" {
  source = "../es-data/terraform"
}

module "es-hq" {
  source = "../es-hq/terraform"
}

module "es-kibana" {
  source = "../es-kibana/terraform"
}

module "es-filebeat" {
  source = "../es-filebeat/terraform"
}

module "es-exportor" {
  source = "../es-exportor/terraform"
}
