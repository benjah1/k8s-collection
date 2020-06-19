# Vault Cluster

Inspire by [vault-helm](https://github.com/hashicorp/vault-helm)

## Script

```
kubectl -n vault apply -f yaml/

# initialize
kubectl -n vault exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl -n vault exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl -n vault exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl -n vault exec vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY

# ui
kubectl -n vault port-forward service/vault-standby --address 0.0.0.0 8200:8200
```
