FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install --yes apt-utils && \
    apt-get dist-upgrade --yes && \ 
    apt-get clean

RUN apt-get install --yes python3-openstackclient && \
    openstack --version
