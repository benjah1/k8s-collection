#!/bin/bash


RES=$(kubectl --context kind-kind get node 2>/dev/null 1>/dev/null)

if [ "$?" == "0" ]
then 
	echo "The cluster is already running!!!"
	exit 1
fi

RES=$(docker image ls | egrep "kind-node +v1")


if [ "$?" == "1" ]
then

	echo ""
	echo "Build image kind-node"
	docker build -t kind-node:v1 -f kind-node.dockerfile .
fi

echo ""
echo "Create cluster"
kind create cluster --config ./kind.yaml

echo ""
echo "Deploy kube-router"
MASTER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-control-plane)

APISERVER=https://${MASTER_IP}:6443

cat kube-router.yaml | \
	sed "s|%APISERVER%|${APISERVER}|g" | \
  kubectl apply -f -

kubectl -n kube-system apply -f ./sa-admin/ 
