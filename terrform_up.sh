docker run \
	-d \
	--name terraform \
	-v /home/vagrant/.kube:/root/.kube \
	-v /home/vagrant/Documents/k8s-collection:/app \
	--entrypoint tail \
	--net host \
	192.168.0.76:38081/root/k8s-collection/devops:latest -f /dev/null
