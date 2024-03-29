#!/bin/bash

RES=$(kubectl --context kind-kind get node 2>/dev/null 1>/dev/null)

if [ "$?" == "0" ]
then 
	echo "The cluster is already running!!!"
	exit 0
fi

echo ""
echo "Create cluster"
sudo rm -rf /home/vagrant/kind-data/pki/
mkdir -p /home/vagrant/kind-data/pki
cp key/ca.key /home/vagrant/kind-data/pki/ca.key
cp key/ca.crt /home/vagrant/kind-data/pki/ca.crt

kind create cluster --config ./kind.yaml

echo ""
echo "Deploy kube-router"
MASTER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)

APISERVER=https://${MASTER_IP}:6443

cat ./yaml/kube-router.yaml | \
	sed "s|%APISERVER%|${APISERVER}|g" | \
  kubectl apply -f -

kubectl -n kube-system apply -f ./yaml/admin-binding.yaml
