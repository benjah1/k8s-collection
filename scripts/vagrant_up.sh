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
			-v /home/benjah1/Documents:/home/benjah1/Documents/ \
			-w /home/benjah1/Documents/dotfiles/1804-ram/ \
			--net host \
			vagrant:test \
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
	docker exec vagrant vagrant ssh -- 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJOt2eCC7Azy/YKfabVuBDG2UOt+uU2zZgA7lMYobTYvs+5z61kDQZHypGwC7cHq4JY8xbovMkq7LbQSOPtkmOaT6LxHIWA4MRALTd5UGxFmoPX2L2twjSbsXCgbb9Q4M5oarVbanwrxAlws+SwnrGQQQNab1/FEHzTi2UhgeRnWiHy0nAP21bxcun5NBCUCj+CgqUTV2iA/dpn3gJExsbuE+VzyWGJquoZLGG5o0JFOmDVlw/OB6eNGjUOK2t6GErQG0cBPMLTw2JV8TmSrC4SVsqBadpwpli7Q82KZxflrAhRvS7JdndSwR5HU0QrkVYPMz14O1GMggdj6tq5rrpP99TWs5mXWXHeKgvBCpiNKdqW78Ft+sNoFKE38CkxUIsjMLVwVb8Xsb/jORK+Te75NRvmH6gkE+wDJ9asK2RVXzHnEXXJ9i7MYEc8Em5rfnfeXIxQDxnO8TD/d+e+CtN3mJIFOHlFyflNJdmK0YSDdPTcP5BkRyQQfvCdnFHbEM= Benjamin@benjamin-pc" >> /home/vagrant/.ssh/authorized_keys'
fi
