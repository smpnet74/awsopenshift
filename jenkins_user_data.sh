#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl wget
sudo apt-get -y install python-pip
sudo pip install awscli
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get -y update
sudo apt-get install -y jenkins
sudo sh /var/lib/dpkg/info/jenkins.postinst configure 1.560