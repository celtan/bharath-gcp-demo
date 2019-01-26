FROM centos:7

MAINTAINER Bharath Raj 

RUN yum -y upgrade \
    && yum install -y \
        initscripts \
        wget \
        libaio \
        telnet \
    && yum -y clean all
