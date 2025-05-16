#!/bin/bash
apt-get update -y
apt-get install -y python3-pip git

pip3 install ansible

git clone https://github.com/sirishap03/apache-playbook.git /opt/ansible
cd /opt/ansible
ansible-playbook -i "localhost," -c local apache.yml
