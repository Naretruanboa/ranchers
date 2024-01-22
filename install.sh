#!/bin/bash

echo Install docker ...
curl https://releases.rancher.com/install-docker/23.0.3.sh | sh

echo Install docker compose ...
apt-get install -y -qq docker-compose > /dev/null

echo set net bridge ...
sysctl net.bridge.bridge-nf-call-iptables

echo Install kubectl ...
snap install kubectl --classic

mkdir /root/rancher
wget https://github.com/kapong/ranchers/raw/main/docker-compose.yml

cd /root/rancher
docker compose up -d

echo "Please wait 2-3 minutes for the installation to complete."

echo "Bootstrap Password"
docker logs rancher-center  2>&1 | grep "Bootstrap Password:"