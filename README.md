# Jenkins PoC

## Spin up your minikube server

```
minikube start
```

that is necessary to get the kube credentials

## Install via Dockerfile

```
docker build -t jenkins .
```

## Run it

```
docker run \
-p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ~/.kube:/var/jenkins_home/.kube \
-v ~/.minikube/ca.crt:/var/jenkins_home/.minikube/ca.crt \
-v ~/.minikube/client.crt:/var/jenkins_home/.minikube/client.crt \
-v ~/.minikube/client.key:/var/jenkins_home/.minikube/client.key \
--name jenkins \
jenkins
```

## Prepare Docker Hub credentials

Just add the docker credentials (username and password) with the name
`dockerhub`. Those are mandatory to push the image in the docker hub registry

_From section credentials add a new global credentials for Docker_

## Prepare Github credentials

Just add the github ssh key with the name `github`. This is mandatory to push
and propose changes to different git repositories.

Create a github token and create a credentials with the name `github_token`.
This is mandatory to propose pull-requests. To create a personal access token
goes here: https://github.com/settings/tokens

## Preapare K8S

Add a new context for Jenkins using the minikube as base

## Expose with ngrok

```
ngrok http 8080
```

Use the HTTPs link for webhooks

## Webhook on Github

Configure the webhook on the github project setting page

Example:

```
https://60d388ef.ngrok.io/github-webhook/
```

# Manual setup

## Install manually

```
docker run \
-p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ~/.kube:/var/jenkins_home/.kube \
-w ~/.minikube/ca.crt:~/.minikube/ca.crt \
-w ~/.minikube/client.crt:~/.minikube/client.crt \
-w ~/.minikube/client.key:~/.minikube/client.key \
--name jenkins \
jenkins
```

## Install Docker in the jenkins container

Bash as root user

```
docker exec -it -u root jenkins bash
```

Add the docker cli

```
apt-get update && \
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
apt-get -y install docker-ce
```

Check the current docker.sock gid

```
ls -las /var/run/docker.sock
0 srw-rw---- 1 0 998 0 Nov  1 10:27 /var/run/docker.sock
```

in this case the 998 gid is the docker group

Create a docker alias

```
groupadd -g 998 dockerhost
```

Add jenkins user to this group

```
usermod -a -G dockerhost jenkins
```

Restart the jenkins container

```
docker restart jenkins
```

### Install kubectl

As root

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod a+x kubectl
mv kubectl /usr/bin/
```

