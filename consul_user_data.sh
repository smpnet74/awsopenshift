#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'
sudo apt-get update
sudo apt-get install -y curl wget unzip python-pip nmon
sudo pip install awscli
CONSUL=0.6.4
cd /tmp
wget https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip -O consul.zip
unzip consul.zip >/dev/null
chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /opt/consul/data
sudo aws s3 cp s3://openshifts3bucket/upstart.conf /tmp/upstart.conf
sudo aws s3 cp s3://openshifts3bucket/consul_flags /tmp/consul_flags
sudo aws s3 cp s3://openshifts3bucket/firststart /tmp/firststart
sudo mkdir -p /etc/consul.d
sudo mkdir -p /etc/service
sudo chown root:root /tmp/upstart.conf
sudo mv /tmp/upstart.conf /etc/init/consul.conf
sudo chmod 0644 /etc/init/consul.conf
sudo mv /tmp/consul_flags /etc/service/consul
sudo chmod 0644 /etc/service/consul
sudo chmod 0777 /tmp/firststart
sudo /tmp/firststart