resource "kubernetes_stateful_set" "es_data" {
  metadata {
    name      = "es-data"
    namespace = "monitoring"

    labels = {
      app = "es-data"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "es-data"
      }
    }

    template {
      metadata {
        labels = {
          app = "es-data"
        }
      }

      spec {
        init_container {
          name    = "init-chown-data"
          image   = "busybox:1.31.1"
          command = ["chown", "-R", "1000:1000", "/usr/share/elasticsearch/data"]

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }

        init_container {
          name    = "configure-sysctl"
          image   = "elasticsearch:7.8.0"
          command = ["sysctl", "-w", "vm.max_map_count=262144"]

          security_context {
            privileged = true
          }
        }

        container {
          name  = "es-data"
          image = "elasticsearch:7.8.0"

          port {
            name           = "http"
            container_port = 9200
          }

          port {
            name           = "transport"
            container_port = 9300
          }

          env {
            name = "node.name"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "discovery.seed_hosts"
            value = "es-master.monitoring"
          }

          env {
            name  = "cluster.name"
            value = "eslab"
          }

          env {
            name  = "network.host"
            value = "0.0.0.0"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xmx512m -Xms512m"
          }

          env {
            name  = "node.master"
            value = "false"
          }

          env {
            name  = "node.data"
            value = "true"
          }

          env {
            name  = "node.ingest"
            value = "false"
          }

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "#!/usr/bin/env bash -e\n# If the node is starting up wait for the cluster to be ready (request params: \"wait_for_status=green&timeout=1s\" )\n# Once it has started only check that the node itself is responding\nSTART_FILE=/tmp/.es_start_file\nhttp () {\n  local path=\"$${1}\"\n  local args=\"$${2}\"\n  set -- -XGET -s\n  if [ \"$args\" != \"\" ]; then\n    set -- \"$@\" $args\n  fi\n  if [ -n \"$${ELASTIC_USERNAME}\" ] && [ -n \"$${ELASTIC_PASSWORD}\" ]; then\n    set -- \"$@\" -u \"$${ELASTIC_USERNAME}:$${ELASTIC_PASSWORD}\"\n  fi\n  curl --output /dev/null -k \"$@\" \"http://127.0.0.1:9200$${path}\"\n}\nif [ -f \"$${START_FILE}\" ]; then\n  echo 'Elasticsearch is already running, lets check the node is healthy'\n  HTTP_CODE=$(http \"/\" \"-w %%{http_code}\")\n  RC=$?\n  if [[ $${RC} -ne 0 ]]; then\n    echo \"curl --output /dev/null -k -XGET -s -w '%%{http_code}' \\$${BASIC_AUTH} http://127.0.0.1:9200/ failed with RC $${RC}\"\n    exit $${RC}\n  fi\n  # ready if HTTP code 200, 503 is tolerable if ES version is 6.x\n  if [[ $${HTTP_CODE} == \"200\" ]]; then\n    exit 0\n  elif [[ $${HTTP_CODE} == \"503\" && \"7\" == \"6\" ]]; then\n    exit 0\n  else\n    echo \"curl --output /dev/null -k -XGET -s -w '%%{http_code}' \\$${BASIC_AUTH} http://127.0.0.1:9200/ failed with HTTP code $${HTTP_CODE}\"\n    exit 1\n  fi\nelse\n  echo 'Waiting for elasticsearch cluster to become ready (request params: \"wait_for_status=green&timeout=1s\" )'\n  if http \"/_cluster/health?wait_for_status=green&timeout=1s\" \"--fail\" ; then\n    touch $${START_FILE}\n    exit 0\n  else\n    echo 'Cluster is not yet ready (request params: \"wait_for_status=green&timeout=1s\" )'\n    exit 1\n  fi\nfi\n"]
            }

            initial_delay_seconds = 10
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 3
            failure_threshold     = 3
          }
        }

        termination_grace_period_seconds = 120

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "app"
                  operator = "In"
                  values = ["es-data"]
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        selector {
          match_labels = {
            app = "es-data"
          }
        }

        resources {
          requests = {
            storage = "5Gi"
          }
        }

        storage_class_name = "standard"
      }
    }

    service_name          = "es-data"
    pod_management_policy = "Parallel"
  }
}

