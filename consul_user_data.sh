#!/usr/bin/env bash
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
sudo aws s3 cp s3://openshifts3bucket/consul-server-count /tmp/consul-server-count
sudo aws s3 cp s3://openshifts3bucket/consul-server-addr /tmp/consul-server-addr
sudo aws s3 cp s3://openshifts3bucket/upstart.conf /tmp/upstart.conf
sudo aws s3 cp s3://openshifts3bucket/consul_flags /tmp/consul_flags
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')
sudo mkdir -p /etc/consul.d
sudo mkdir -p /etc/service
sudo chown root:root /tmp/upstart.conf
sudo mv /tmp/upstart.conf /etc/init/consul.conf
sudo chmod 0644 /etc/init/consul.conf
sudo mv /tmp/consul_flags /etc/service/consul
sudo chmod 0644 /etc/service/consul
sudo start consul