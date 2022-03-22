FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y
#RUN apt-get install zip unzip
#RUN apt-get install -y wget
#RUN apt-get install -y python3
#RUN apt-get install -y python3-pip
#RUN apt-get install -y default-jdk
RUN apt-get install openjdk-11-jdk -y --fix-missing
RUN apt-get install -y maven
ADD . /home/devoteam-traineeship-petclinic
WORKDIR /home/devoteam-traineeship-petclinic
#CMD [ "mvn package", "cargo:run" ]