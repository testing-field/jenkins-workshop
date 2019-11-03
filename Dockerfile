FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
apt-get -y install apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common && \
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable" && \
apt-get update && \
apt-get -y install docker-ce docker-compose

RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list \
&&      apt-get update              \
&&      apt-get install -y git hub  \
&&      apt-get clean all

RUN groupadd -g 998 dockerhost
RUN usermod -a -G dockerhost jenkins

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod a+x kubectl
RUN mv kubectl /usr/bin

RUN curl -LO https://github.com/mozilla/sops/releases/download/3.4.0/sops-3.4.0.linux
RUN chmod a+x sops-3.4.0.linux
RUN mv sops-3.4.0.linux /usr/bin/sops

USER jenkins
