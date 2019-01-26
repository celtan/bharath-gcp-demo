FROM asia.gcr.io/hip-microservices-experiment-2/centos-base

MAINTAINER Bharath Raj

RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jre-8u201-linux-x64.rpm" \
  && yum localinstall jre-8u201-linux-x64.rpm -y \
  && rm -f jre-8u201-linux-x64.rpm

WORKDIR /opt
