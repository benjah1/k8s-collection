resource "kubernetes_namespace" "monitoring" {
	metadata {
		name = "monitoring"
	}
}

module "prometheus" {
  source = "../prometheus/terraform"
}
