#!/bin/bash
##########################################
# Script to install docker and zimbra zcs
# idc at macromind dot online
##########################################
set -e

if [[ "$(id -u)" != "0" ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ ${1} == "" || ${2} == "" ]] ; then
    echo 'Please, inform the mail server hostname and admin password. e.g. ./install.sh mail.mydomain.com p4ssw0rd'
    exit 0
fi

echo "==============================================="
echo "Setting variables and hostname"
DOCKER_HOSTNAME=docker-node-${RANDOM}
MAIL_HOSTNAME=${1}
MAIL_SECRET=${2}
hostnamectl set-hostname ${DOCKER_HOSTNAME} &>/dev/null
echo "Mail server hostname: ${MAIL_HOSTNAME}"
echo "Mail admin password: ${MAIL_SECRET}"
echo "Docker hostname: ${DOCKER_HOSTNAME}"

echo "Updating apt packages…"
apt update &>/dev/null && apt dist-upgrade -y &>/dev/null
apt install vim-nox htop atop nload ncdu pv netcat build-essential apt-transport-https ca-certificates software-properties-common curl dnsutils -y &>/dev/null

echo "Installing Docker CE"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - &>/dev/null
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" &>/dev/null
apt update &>/dev/null && apt install docker-ce -y &>/dev/null

echo "Installing Docker Compose"
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>/dev/null
chmod 700 /usr/local/bin/docker-compose

echo "Creating Docker Compose yml file"
cat <<EOF >>/root/docker-compose.yml
version: "3.4"
services:
 mail:
  image: macromind/docker-zimbra:latest
  restart: always
  hostname: $MAIL_HOSTNAME
  environment:
   - PASSWORD=$MAIL_SECRET
  ports:
   - 25:25
   - 80:80
   - 110:110
   - 143:143
   - 443:443
   - 465:465
   - 587:587
   - 993:993
   - 995:995
   - 3443:3443
   - 5222:5222
   - 5223:5223
   - 7071:7071
   - 8080:8080
   - 8443:8443
   - 9071:9071
  networks:
   - mail_network
networks:
 mail_network:
EOF

echo "All done…"
echo "==============================================="
