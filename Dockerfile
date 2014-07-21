##################################################
# Dockerfile for building a maven project
# Based on Obuntu 14.04
#  with
#   - maven
#   - git
#   - java Oracle 7
# maven install includes:
#  - google protocol buffers
#  - maven-protoc-plugin
#
# user ubuntu with password ubuntu is added to system
# can use sudo
##################################################

FROM ubuntu:14.04

RUN apt-get update
RUN apt-get upgrade -y

# Needed for mkpasswd
RUN apt-get install -y whois

RUN useradd -m -G sudo -p `mkpasswd docker` ubuntu

RUN chsh -s /bin/bash $USER_LOGIN
RUN su - ubuntu -c "touch /home/ubuntu/.bashrc"


# instal software-properties-common
RUN apt-get install -y software-properties-common

# Install Java.
RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer

# set JAVA_HOME env reference
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-7-oracle/" >> /etc/environment

# install maven
RUN apt-get install -y maven

# install git
RUN apt-get install -y git

# install needed packages for compiling c and c++ code
RUN apt-get install -y gcc make g++ wget

# download and install google protocol buffers
RUN cd /tmp && \
wget https://protobuf.googlecode.com/files/protobuf-2.4.1.tar.gz && \
tar xvfk protobuf* && \
cd protobuf-2.4.1 && \
./configure && \
make && \
make install && \
export LD_LIBRARY_PATH=/lib:/usr/local/lib && \
ldconfig


# download and still maven-protoc-plugin
RUN cd /tmp && \ 
mkdir test && \
wget http://github.com/sergei-ivanov/maven-protoc-plugin/archive/maven-protoc-plugin-0.3.2.tar.gz && \
tar xvfk maven* && \
cd maven-protoc-plugin-maven-protoc-plugin-0.3.2/ && \
mvn install

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get autoremove -y

VOLUME /data

VOLUME /.m2

CMD["bash"]

