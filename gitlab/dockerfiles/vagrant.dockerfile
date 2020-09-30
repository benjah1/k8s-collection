FROM debian:10.5

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto

RUN apt-get update && apt-get install wget gnupg1 -y && \
		wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - && \
		echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bionic contrib" | tee /etc/apt/sources.list.d/virtualbox.list

RUN apt-get update && apt-get install virtualbox-6.1 vagrant -y
RUN vagrant box add ubuntu/bionic64
RUN vagrant plugin install vagrant-disksize && \
    vagrant plugin install vagrant-vbguest
RUN vboxmanage setproperty machinefolder /vm

CMD ['tail', '-f', '/dev/null']
