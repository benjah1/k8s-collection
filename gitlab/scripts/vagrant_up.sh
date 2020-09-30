#!/bin/bash 

echo "checking docker vagrant container..."
RES=$(docker ps | grep vagrant)
if [ "$?" == "1" ]
then
	echo "docker vagrant not running."
	RES=$(docker ps -a | grep vagrant)
	if [ "$?" == "1" ]
	then
		echo "docker vagrant doesn't exist. Create now..."
		docker run -d \
			--name vagrant \
			--privileged \
			--mount type=tmpfs,destination=/vm,tmpfs-size=30g \
			-v $(pwd)/dotfiles:/home/benjah1/Documents/dotfiles \
			-w /home/benjah1/Documents/dotfiles/1804-ram/ \
			--net host \
			192.168.0.76:38081/root/k8s-collection/vagrant:latest \
			tail -f /dev/null
	else
		echo "docker vagrant is not running. Start now..."
		docker start vagrant
	fi
fi

echo "checking vbox vm id..."
ID=$(docker exec vagrant vboxmanage list vms | grep inaccessible | egrep -o ".{8}-.{4}-.{4}-.{4}-.{12}")

if [ ! -z "$ID" ]
then 
	echo "Found ${ID}..."
	echo ${ID} | xargs -I {} docker exec vagrant vboxmanage unregistervm {} --delete
	VID=$(docker exec vagrant vagrant global-status | grep 1804-ram | awk '{print $1}')
	echo ${VID} | xargs -I {} docker exec vagrant vagrant destroy {}
fi

echo "checking vagrant status..."
STATUS=$(docker exec vagrant vagrant global-status | grep 1804-ram | grep running)

if [ "$?" == "1" ]
then 
	echo "starting vagrant"
	docker exec -it vagrant vagrant up 

	echo "inserting ssh public key"
	echo "${1}"
	docker exec vagrant vagrant ssh -- "echo '${1}' >> /home/vagrant/.ssh/authorized_keys"
fi
