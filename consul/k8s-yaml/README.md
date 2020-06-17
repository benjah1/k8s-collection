# Consul

Inspire by [consul-on-kubernetes](https://github.com/kelseyhightower/consul-on-kubernetes)

## Script

```
kubectl create ns consul

docker run --rm -v $(pwd)/ca:/root/ca -w /root/ca --entrypoint bash cfssl/cfssl -c "cfssl gencert -initca ca-csr.json | cfssljson -bare ca"

docker run --rm -v $(pwd)/ca:/root/ca -w /root/ca --entrypoint bash cfssl/cfssl -c "cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=default \
  consul-csr.json | cfssljson -bare consul"

# start up
GOSSIP_ENCRYPTION_KEY=Ut5scRdr21sVwuE3ePCLKIYWOCNGEIAuX1wYOB6/u3A= # $(consul keygen)
kubectl -n consul create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=ca/ca.pem \
  --from-file=ca/consul.pem \
  --from-file=ca/consul-key.pem
kubectl -n consul create configmap consul --from-file=configs/server.json
kubectl -n consul apply -f yaml/pv.yaml
kubectl -n consul apply -f yaml/service.yaml
kubectl -n consul apply -f yaml/serviceaccount.yaml
kubectl -n consul apply -f yaml/clusterrole.yaml
kubectl -n consul apply -f yaml/statefulset.yaml

# clean up for re-run
kubectl -n consul delete -f statefulset.yaml
kubectl -n consul delete-pvc data-consul-0 data-consul-1 data-consul-2
kubectl -n consul delete-f pv.yaml

```
