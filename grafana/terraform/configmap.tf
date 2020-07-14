resource "kubernetes_config_map" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }

  data = {
    "dashboards.yaml" = "apiVersion: 1\nproviders:\n- name: 'default-dashboards'\n  orgId: 1\n  folder: 'default'\n  folderUid: ''\n  type: file\n  disableDeletion: false\n  editable: true\n  updateIntervalSeconds: 10\n  allowUiUpdates: false\n  options:\n    path: /var/lib/grafana/dashboards\n    foldersFromFilesStructure: true\n"

    "datasources.yaml" = "apiVersion: 1\ndatasources:\n- name: Prometheus\n  type: prometheus\n  url: prometheus.monitoring:9090\n  isDefault: true\n"

    "grafana.ini" = "[paths]\n  data = /var/lib/grafana/data\n  logs = /var/log/grafana\n  plugins = /var/lib/grafana/plugins\n  provisioning = /etc/grafana/provisioning\n[analytics]\n  check_for_updates = true\n[log]\n  mode = console\n"
  }
}

