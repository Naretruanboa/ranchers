#!/bin/bash

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

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

echo "Done, you should reboot now."

echo "After reboot, run this command to start rancher server:" 
echo "docker compose up -d\n"
echo "and"
echo 'docker logs rancher-center  2>&1 | grep "Bootstrap Password:"'

# echo "Please wait 2-3 minutes for the installation to complete."

# sleep 180
# echo "Bootstrap Password"
# docker logs rancher-center  2>&1 | grep "Bootstrap Password:"