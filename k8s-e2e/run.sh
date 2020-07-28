#!/bin/bash 

RES=$(docker ps | grep e2e)

if [ "$?" == "1" ]
then
	docker run -d \
		--name k8s-e2e \
		-v $(pwd):/app \
		-v $HOME/.kube:/root/.kube \
		--net host \
		-w / \
		golang:1.14 \
		tail -f /dev/null

  docker cp $(which kubectl) k8s-e2e:/bin
fi

docker exec -it k8s-e2e bash ./app/script/test.sh
