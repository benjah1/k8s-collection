docker run \
	-d \
	--name terraform \
	-v /home/vagrant/.kube:/root/.kube \
	-v /home/vagrant/Documents/k8s-collection:/app \
	--entrypoint tail \
	--net host \
	hashicorp/terraform:0.13.3 -f /dev/null
