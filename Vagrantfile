# -*- mode: ruby -*-
# vi: set ft=ruby :
# README
#
# Getting Started:
# 1. vagrant up 
# 2. vagrant ssh control
#
# This should put you at the control host
#  with access, by name, to other vms
Vagrant.configure(2) do |config|
  required_plugins = [
    "vagrant-hostmanager",
    "vagrant-share",
    "vagrant-vbguest"
  ]
  required_plugins.each do |plugin|
    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
  end
  config.vm.define "control", primary: true do |h|
    h.vm.box = "generic/ubuntu2204"
    h.vbguest.installer_hooks[:before_install] = ["apt update && apt upgrade -y", "sleep 5"]
    h.vm.hostname =  "control"
    h.vm.network "private_network", ip: "192.168.60.10"
    h.vm.network "forwarded_port", guest: 22, host: "2200", id: "ssh"
    h.vm.synced_folder ".", "/vagrant"
    h.vm.provision :shell, inline: "echo 'export ANSIBLE_CONFIG=/vagrant/ansible/ansible.cfg' >> /home/vagrant/.bash_profile"
    h.vm.provision "shell" do |provision|
      provision.path = "provision_ansible.sh"
    end 
    h.vm.provision :shell, :inline => <<'EOF'
    if [ ! -f "/home/vagrant/.ssh/id_rsa" ]; then
      ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
    fi
    
   yes | cp -r /home/vagrant/.ssh/id_rsa.pub /vagrant/control.pub
    
    cat << 'SSHEOF' > /home/vagrant/.ssh/config
    Host *
      StrictHostKeyChecking no
      UserKnownHostsFile=/dev/null
SSHEOF
    chown -R vagrant:vagrant /home/vagrant/.ssh/
EOF
    h.vm.provider "virtualbox" do |vm|
        vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vm.name = "control"
        vm.cpus = 2
        vm.memory = 2048
    end
    h.vm.provision 'shell', reboot: true
  end

  config.vm.define "app01" do |h|
    h.vm.box = "generic/ubuntu2204"
    h.vbguest.installer_hooks[:before_install] = ["apt update && apt upgrade -y", "sleep 5"]
    h.vm.hostname = "app01"
    h.vm.network "private_network", ip: "192.168.60.111"
    h.vm.network "forwarded_port", guest: 22, host: "2201", id: "ssh"
    h.vm.synced_folder ".", "/vagrant"
    h.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    h.vm.provision 'shell', reboot: true
    h.vm.provider "virtualbox" do |vm|
      vm.name = "app01"
      vm.cpus = 1
      vm.memory = 1024
    end
  end

  config.vm.define "app02" do |h|
    h.vm.box = "rockylinux/9"
    h.vbguest.installer_hooks[:before_install] = ["yum clean all && yum reploist && yum update -y && yum -y install kernel-headers kernel-devel binutils gcc make patch libgomp glibc-headers glibc-devel elfutils-libelf-devel rsync", "sleep 5"]
    h.vm.hostname = "app02"
    h.vm.network "private_network", ip: "192.168.60.112"
    h.vm.network "forwarded_port", guest: 22, host: "2202", id: "ssh"
    h.vm.synced_folder ".", "/vagrant"
    h.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    h.vm.provision :shell, inline: 'test -e /usr/bin/python3 || (yum install -y python3)'
    h.vm.provision 'shell', reboot: true
    h.vm.provider "virtualbox" do |vm|
      vm.name = "app02"
      vm.cpus = 1
      vm.memory = 1024
    end
  end

  config.vm.define "app03" do |h|
    h.vm.box = "peru/windows-server-2016-standard-x64-eval"
    h.vm.hostname = "app03"
    h.vm.network "private_network", ip: "192.168.60.113"
    h.vm.guest = :windows
    h.vm.communicator = "winrm"
    h.vm.boot_timeout = 300
    h.vm.graceful_halt_timeout = 300
    h.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    h.vm.provision "shell", path: "scripts/windows/install-sshd.ps1", powershell_elevated_interactive: false 
    h.vm.provision "shell", path: "scripts/windows/ConfigureRemotingForAnsible.ps1", powershell_elevated_interactive: false 
    h.vm.provider "virtualbox" do |vm|
      vm.name = "app03"
        vm.gui = false
        vm.cpus = 2
        vm.memory = 4096
    end
  end
end
