resource "null_resource" "vault_init" {
  triggers = {
    cluster_instance_ids = kubernetes_stateful_set.vault.id
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/script/vault_init.py"
  }
}
