# Kubernetes e2e test with kind


## Note

* Bazel must be 0.23.2. see [link](https://github.com/kubernetes-sigs/kind/issues/1181)
* I use k8s 1.18.2 in the folder k8s-cluster. Change it as you need.

## Script


```
curl -Lo bazel.sh https://github.com/bazelbuild/bazel/releases/download/0.23.2/bazel-0.23.2-installer-linux-x86_64.sh
sudo bash ./bazel.sh
bazel version # must be Build label: 0.23.2
curl -Lo k8s https://github.com/kubernetes/kubernetes/archive/v1.18.2.tar.gz # depends on your kind cluster version
mv k8s k8s_1.18.2.tar.gz
tar -xvf k8s_1.18.2.tar.gz
cd kubernetes-1.18.2
bazel build //test/e2e:e2e.test
export KUBECONFIG="${HOME}/.kube/config"
bazel-bin/test/e2e/e2e.test -context kind-kind
```

