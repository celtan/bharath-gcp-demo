FROM registry.access.redhat.com/rhel7

MAINTAINER Bharath Raj 

RUN ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime
COPY yum/epel.repo /etc/yum.repos.d/epel.repo
RUN yum -y install epel-release \
    && yum -y upgrade \
    && yum install -y \
        initscripts \
        wget \
        libaio \
        python-pip \
        unzip \
        zip \
        telnet \
    && yum -y clean all \
    && pip install pip --upgrade \
    && pip install supervisor \
    && rm -fr ~/.cache/pip/*
