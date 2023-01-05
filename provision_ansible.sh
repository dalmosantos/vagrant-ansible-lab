#!/bin/bash
echo "Starting provisioning of Ansible..."

sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt install -y ansible \
    software-properties-common \
    python3-setuptools \
    python3-dev \
    git \
    python3-pip
pip3 install "yamllint" "ansible-lint" "pywinrm"
sudo ansible-galaxy install deekayen.win_updates
sudo ansible-galaxy install mrlesmithjr.windows-iis
sudo cat << 'HOSTEOF' >> /etc/hosts
192.168.60.10 control
192.168.60.111 app01
192.168.60.112 app02
192.168.60.113 app03
HOSTEOF