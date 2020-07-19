resource "kubernetes_config_map" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }

  data = {
    "container.json" = "${file("${path.module}/dashboards/container.json")}"
    "node.json" = "${file("${path.module}/dashboards/node.json")}"

    "dashboards.yaml" = "${file("${path.module}/config/dashboards.yaml")}"
    "datasources.yaml" = "${file("${path.module}/config/datasources.yaml")}"
    "grafana.ini" = "${file("${path.module}/config/grafana.ini")}"
  }
}

