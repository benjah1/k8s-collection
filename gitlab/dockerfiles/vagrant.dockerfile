FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Toronto

RUN apt-get update
RUN apt-get install virtualbox -y
RUN apt-get install vagrant -y
RUN vagrant box add ubuntu/bionic64
RUN vagrant plugin install vagrant-disksize && \
    vagrant plugin install vagrant-vbguest
RUN vboxmanage setproperty machinefolder /vm

CMD ['tail', '-f', '/dev/null']
