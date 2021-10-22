# docker-apps
Manage local docker apps

## Linux Prerequisite
* git
```shell
# Archlinux
➜ sudo pacman -S git --noconfirm
```
* docker
```shell
# Archlinux
➜ sudo pacman -S docker --noconfirm
```
* docker-compose
```shell
# Archlinux
➜ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
➜ sudo chmod +x /usr/local/bin/docker-compose
```
* docker configuration
```shell
# Archlinux
➜ sudo groupadd docker; sudo chmod 666 /var/run/docker.sock; sudo usermod -aG docker ${USER}; docker login
# You must configure docker proxies (https://docs.docker.com/network/proxy/) even if empty
➜ systemctl restart docker
```

* cgroups configuration 
```shell
# Enable cgroups v1 
# Edit /etc/default/grub
# Add systemd.unified_cgroup_hierarchy=0 
# to the key GRUB_CMDLINE_LINUX_DEFAULT (space separated list)
➜ run sudo grub-mkconfig -o /boot/grub/grub.cfg 
# And reboot.
```

## Install
* Create network
* Create directories
* Install bin 

```shell
➜ sudo -- sh -c './install.sh'
➜ docker-apps -h            
Manage local docker apps
  
Usage : 
  docker-apps [OPTIONS] COMMAND APPS
  
Options :
  -l --lib-path : Set lib path
  -h --help: Display usage
  
Commands :
  infos : Display apps infos  
  install : Install docker-apps
  list : List local docker apps
  ps: List apps containers
  start : Start local docker apps
  stop : Stop local docker apps
  uninstall : Uninstall docker-apps  
  
Exemple: 
  ./docker-apps start gitlab jenkins --lib-path .
  
Exemple (docker-apps installed): 
  docker-apps start gitlab jenkins

```

## Uninstall
```shell
➜ docker-apps uninstall
➜ # sudo rm -rf /srv/{docker-registry,elk,elasticsearch,gitlab,jenkins}
```

## Overview

| Name   |      Image      |  Ports |  Ip |
|----------|:-------------:|:------:|:------:|
| docker-registry.local | registry:2 | 5000:5000 ||
| gitlab.local | gitlab/gitlab-ce:latest | 882:80 <br> 8082:8080 <br> 5002:5000 | 192.168.38.2 |
| jenkins.local | jenkins/jenkins:lts-jdk11 | 883:80 <br> 8083:8080 <br> 50000:50000 | 192.168.38.3 |
| elasticsearch.local | elasticsearch:7.7.0 | 9200:9200 <br> 9300:9300 | 192.168.38.5 |
| elk-elasticsearch.local| elasticsearch:7.7.0 | 9206:9200 <br> 9306:9300 | 192.168.38.6 |
| elk-kibana.local| kibana:7.7.0 | 5601:5601 | 192.168.38.7 |
| elk-logstash.local | logstash:7.7.0 | 9600:9600 <br> 5008:5000 | 192.168.38.8 |


## Apps

### Docker registry

#### Run
```shell
➜ docker-apps start docker-registry
```

#### Configure
```shell
➜ sudo openssl req \
   -newkey rsa:4096 -nodes -sha256 -keyout /srv/docker-registry/certs/localhost.key \
  -x509 -days 365 -out /srv/docker-registry/certs/localhost.crt \
  -addext 'subjectAltName = IP:127.0.0.1,DNS:docker-registry.local'

➜ sudo htpasswd -B /srv/docker-registry/auth/htpasswd admin
```

#### Test
```shell
➜ curl https://localhost:5000/v2/_catalog -u admin:password --insecure
```

### Gitlab

#### Run
```shell
➜ docker-apps start gitlab
```
#### Configure

```shell
➜ docker exec  gitlab.local cat /etc/gitlab/initial_root_password \
  | grep Password: | awk '{print $2}'
```

#### Test
```shell
➜ curl http://localhost:882
➜ curl http://192.168.38.2
```

### Jenkins

#### Run
```shell
➜ docker-apps start jenkins
```

#### Configure

```shell
➜ docker exec jenkins.local cat /var/jenkins_home/secrets/initialAdminPassword
```

#### Test
```shell
➜ curl http://localhost:8083
➜ curl http://192.168.38.3:8080
```

### Elasticsearch

#### Run
```shell
➜ docker-apps start elasticsearch
```

#### Test
```shell
➜ curl http://localhost:9200
```

### ELK

#### Run
```shell
➜ docker-apps start elk
```

#### Test
```shell
➜ curl http://localhost:9206\?pretty
➜ curl http://localhost:5601/api/status\?pretty
➜ curl http://localhost:9600\?pretty

```
