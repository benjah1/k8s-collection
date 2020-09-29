FROM debian:10.5

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto

RUN apt-get update && apt-get install virtualbox vagrant -y
RUN vagrant box add ubuntu/bionic64
RUN vagrant plugin install vagrant-disksize && \
    vagrant plugin install vagrant-vbguest
RUN vboxmanage setproperty machinefolder /vm

CMD ['tail', '-f', '/dev/null']
