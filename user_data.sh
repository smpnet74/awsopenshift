#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl wget
sudo apt-get -y install python-pip
sudo pip install awscli
sudo aws s3 cp s3://openshifts3bucket/nexus-3.0.2-02-unix.tar.gz /home/ubuntu
sudo tar -zxf /home/ubuntu/nexus-3.0.2-02-unix.tar.gz
