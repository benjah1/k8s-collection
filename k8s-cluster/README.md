# Kubernetes cluster with kind

## Note

* Using Kubernetes 1.18.2

## Script

```
kind create cluster --config kind.yaml
```


```
CLUSTERCIDR=10.244.0.0/16 # default by kind
APISERVER=https://172.18.0.3:6443
sh -c 'curl https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/generic-kuberouter-all-features.yaml -o - | \
sed -e "s;%APISERVER%;172.18.0.3:6443;g" -e "s;%CLUSTERCIDR%;10.244.0.0/16;g"' | \
kubectl apply -f -

```
