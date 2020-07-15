resource "kubernetes_namespace" "monitoring" {
	metadata {
		name = "monitoring"
	}
}

module "prometheus" {
  source = "../prometheus/terraform"
}

module "node-exporter" {
  source = "../node-exporter/terraform"
}

module "grafana" {
  source = "../grafana/terraform"
}
