resource "null_resource" "consul_init" {
  triggers = {
    cluster_instance_ids = kubernetes_stateful_set.consul.id
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/script/consul_init.py"

    environment = {
      CONSUL_TOKEN = random_uuid.token.result
    }
  }
}
