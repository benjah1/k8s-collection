resource "kubernetes_config_map" "filebeat_config" {
  metadata {
    name      = "filebeat-config"
    namespace = "monitoring"

    labels = {
      app = "filebeat"
    }
  }

  data = {
    "filebeat.yml" = "filebeat.inputs:\n- type: container\n  paths:\n    - /var/log/containers/*.log\n  processors:\n  - add_kubernetes_metadata:\n      host: $${NODE_NAME}\n      matchers:\n      - logs_path:\n          logs_path: \"/var/log/containers/\"\n\noutput.elasticsearch:\n  hosts: 'http://es-master.monitoring:9200'\n  index: \"container-%%{[fields.log_type]}-%%{[agent.version]}-%%{+yyyy.MM.dd}\" \n\nsetup.template.name: \"container\"\nsetup.template.pattern: \"container-*\"\n"
  }
}

