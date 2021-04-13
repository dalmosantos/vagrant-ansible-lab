#!/bin/bash
echo "Starting provisioning of Ansible..."

sudo apt-get update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt install -y ansible=2.9.6+dfsg-1 software-properties-common python3-setuptools python3-dev git python3-pip
