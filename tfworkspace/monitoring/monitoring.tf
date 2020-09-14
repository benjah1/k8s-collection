resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
/* // doesn't work anymore
    annotations = {
      "net.beta.kubernetes.io/network-policy" = <<-EOL
      {
        "ingress": {
          "isolation": "DefaultDeny"
        }
      }
EOL
    }
*/
  }
}

resource "kubernetes_network_policy" "monitoring_ingress_default_deny" {
  metadata {
    name      = "ingress-default-deny"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

module "prometheus" {
  source = "../../prometheus/terraform"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
  replicas = 3
}

module "grafana" {
  source = "../../grafana/terraform"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
}

module "node-exporter" {
  source = "../../node-exporter/terraform"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
}

module "es-master" {
  source = "../../es-master/terraform"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
  resource_cpu = var.es_resource_cpu
  resource_memory = var.es_resource_memory
  heap_size = var.es_heap_size
  image_busybox = var.es_image_busybox
  image_elasticsearch = var.es_image_elasticsearch
}

module "es-data" {
  source = "../../es-data/terraform"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
  resource_cpu = var.es_resource_cpu
  resource_memory = var.es_resource_memory
  heap_size = var.es_heap_size
  image_busybox = var.es_image_busybox
  image_elasticsearch = var.es_image_elasticsearch
}

module "es-hq" {
  source = "../../es-hq/terraform"
}

module "es-kibana" {
  source = "../../es-kibana/terraform"
}

module "es-filebeat" {
  source = "../../es-filebeat/terraform"
}

module "es-exportor" {
  source = "../../es-exportor/terraform"
}
