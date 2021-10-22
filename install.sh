#!/bin/bash
cd "$(dirname "$0")"

# Reset
Color_Off='\033[0m'
Error='\033[0;31m'
INFO='\033[0;34m'

PrintInfo() {
  echo -e "$Info[INFO] $1 $Color_Off"
}

PrintInfo "Creating network ..."
docker network create --ipam-driver=default --subnet=192.168.38.0/24 docker-apps-local
PrintInfo "Network created ..."

PrintInfo "Creating directories ..."
echo "ElasticSearch"
mkdir -p /srv/elasticsearch/{data,logs}
chown -R 1000:root /srv/elasticsearch

echo "ELK"
mkdir -p /srv/elk/elasticsearch/{data,logs}
mkdir -p /srv/elk/kibana/data
mkdir -p /srv/elk/logstash/{data,pipeline}
chown -R 1000:root /srv/elk

echo "Docker Registry"
mkdir -p /srv/docker-registry/{auth,certs,data}

PrintInfo "Directories created"

PrintInfo "Configuring Docker Registry"
openssl req \
   -newkey rsa:4096 -nodes -sha256 -keyout /srv/docker-registry/certs/localhost.key \
  -x509 -days 365 -out /srv/docker-registry/certs/localhost.crt \
  -addext 'subjectAltName = IP:127.0.0.1,DNS:docker-registry.local'

PrintInfo "Docker Registry Admin password"
htpasswd -B -c /srv/docker-registry/auth/htpasswd admin

PrintInfo "Docker Registry configured"

PrintInfo "Installing docker-apps bin ..."
./docker-apps install
PrintInfo "docker-apps bin installed"

