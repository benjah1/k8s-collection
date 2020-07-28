#!/bin/bash

K8S_VERSION=1.18.2

apt-get update && apt-get install -y unzip patch

# must be Build label: 0.23.2
RES=$(bazel version)
if [ "$?" != "0" ]
then
	curl -Lo bazel.sh https://github.com/bazelbuild/bazel/releases/download/0.23.2/bazel-0.23.2-installer-linux-x86_64.sh
  bash ./bazel.sh
fi	

if [ ! -d "./kubernetes-${K8S_VERSION}" ]
then
	curl -Lo k8s https://github.com/kubernetes/kubernetes/archive/v${K8S_VERSION}.tar.gz # depends on your kind cluster version
mv k8s k8s_${K8S_VERSION}.tar.gz
tar -xvf k8s_${K8S_VERSION}.tar.gz
fi

cd kubernetes-${K8S_VERSION}
bazel build //test/e2e:e2e.test
export KUBECONFIG="${HOME}/.kube/config"
bazel-bin/test/e2e/e2e.test -context kind-kind
