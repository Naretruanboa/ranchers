#!/bin/bash

echo Install docker ...
curl https://releases.rancher.com/install-docker/23.0.3.sh | sh

echo Install docker compose ...
apt-get install -y -qq docker-compose > /dev/null

echo set net bridge ...
sysctl net.bridge.bridge-nf-call-iptables

echo Install kubectl ...
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

mkdir /root/rancher

cd /root/rancher
wget https://github.com/kapong/ranchers/raw/main/docker-compose.yml
docker compose up -d

echo "Please wait 2-3 minutes for the installation to complete."

sleep 180
echo "Bootstrap Password"
echo 'docker logs rancher-center  2>&1 | grep "Bootstrap Password:"'
docker logs rancher-center  2>&1 | grep "Bootstrap Password:"