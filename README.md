# Vagrant Ansible Lab

This lab is based on the Udemy course https://www.udemy.com/mastering-ansible/
The lab has been built with Virtualbox VM host, and may not work with other VM providers without modification.
This lab does not use Ansible via Vagrant, and thus Ansible is not a requirement on your Vagrant host. Ansible will be installed on an ansible host VM, and all playbooks to configure the lab machines will be run from there interactively, once Vagrant has built the base VMs. The lab configures a simple nginx load balancer, 2 web app servers and a mysql database.

The lab will implement the following configuration:

-
| Machine  Name | Role          | Network Configuration                  | OS                         |
|---------------|---------------|----------------------------------------|----------------------------|
| control       | Ansible  host | private_network, ip: 192.168.135.10    | Ubuntu Focal64 (20 LTS)   |
| app01         | web server 1  | private_network, ip: 192.168.135.111   | Ubuntu Focal64 (20 LTS)   |
| app02         | web server 2  | private_network, ip: 192.168.135.112   | Centos 7   |


## Prerequisites
* Install the Vagrant 2.2.15 from https://www.vagrantup.com/downloads
* Install the Virtualbox 6.1.18 from https://www.virtualbox.org/wiki/Downloads if it is not installed already.
* Download the Vagrant boxes for your preferred hypervisor:
  ```
  $ vagrant box add centos/7
  $ vagrant box add ubuntu/focal64
  ```

## Quick Start
* Clone this repo
* Ensure you have installed Vagrant and Virtualbox(check `Prerequisites` section)
* Run `vagrant up` from the root of the cloned repo (the folder with Vagrantfile in it)
* Once the VMs are built, type `vagrant ssh control` to logon to the ansible controller from within your vagrant project folder
* Change directories `cd /vagrant/ansible` which is the ansible subfolder of your vagrant project for this lab (the vagrant project folder is mounted within the VMs as /vagrant during provisioning)


#Exploring the details
* ./hosts
  * file defining the servers to be orchestrated
* ./ansible.cfg
  * defines hosts file location and ansible vault password file location
* ./group_vars/all/vars
  * global variables file, includes database name and login user info
* ./group_vars/all/vault
  * file encrypted containing database user password (vault_db_pass) 
  * you can view and edit the file with `ansible-vault edit group_vars/all/vault` - your decryption key specified in ansible.cfg will be used to decrypt and reencrypt the file transparently
* ./site.yml - main playbook wrapper, which includes playbooks for the various server types, such as loadbalancer.yml, for building the front end load balancer
*  ./loadbalancer.yml
  *  defines affected hosts ("loadbalancer", which in turn is a group defined in ./hosts file)
  *  references the role of type nginx, which means to include running the playbook in playbooks/roles/tasks/main.yml
  * (same idea for database.yml, control.yml, webserver.yml)
* ./playbooks/roles/nginx (same concept for each role in playbooks/roles/*)
  * ./playbooks/roles/nginx/defaults/main.yml variable defaults
  * ./playbooks/roles/nginx/vars/main.yml variables, if defined here would override the ones in defaults folder
  * ./playbooks/roles/nginx/handlers/main.yml handler definitions for "notify" actions in tasks
  * ./playbooks/roles/nginx/tasks/main.yml task step definitions
  * ./playbooks/roles/nginx/templates/nginx.conf.j2 config file template, used in the "configure nginx site" step in tasks/main.yml, using the "template:" module to customize the .j2 file template into nginx.conf

## Examples

### Working With Inventory

List all hosts:
```
$ ansible --list-hosts all
$ ansible --list-hosts "*"
```

List hosts from specific group:
```
$ ansible --list-hosts loadbalancer
```

List hosts using wildcard filter
```
$ ansible --list-hosts "app*"
```

List hosts from multiple groups
```
$ ansible --list-hosts database,control
```

List first node in webserver group:
```
$ ansible --list-hosts webserver[0]
```

List hosts not in control group:
```
$ ansible --list-hosts \!control
```

### Adhoc Command Examples

Ping all of the hosts:
```
$ ansible -m ping all
```

Run `hostname` command on target hosts:
```
$ ansible -m command -a "hostname" all
```

Run `hostname` command on target hosts(here we are not passing module, `command` module is the default one):
```
$ ansible -a "hostname" all
```

### Playbook Examples

Simple playbook that executes "hostname" command:
```shell
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/hostname.yml
```

Show what hosts are involved in this playbook:
```
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/hostname.yml --list-hosts
```

Show what tags are involved in this playbook:
```
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/hostname.yml --list-tags
```

Run only steps in a playbook that have a tag called "packages" defined:
```shell
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/site.yml --tags "packages"
```

Run only steps in a playbook that DON'T have a tag called "packages" defined:
```
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/site.yml --skip-tags "packages"
```

Step through tasks and be prompted whether to run each step or not:
```
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/site.yml --step
```

Show all tasks that will be executed by the playbook:
```
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/site.yml --list-tasks
```

Skip over steps in a playbook and start at a specific task:
```
$ ansible-playbook -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/stack_status.yml --start-at-task "verify end-to-end response"
```

Verify syntax:
```
$ ansible-playbook --syntax-check /vagrant/ansible/playbooks/site.yml
```

Do a simulated run of the playbook:
```
$ ansible-playbook --check -i /vagrant/ansible/hosts /vagrant/ansible/playbooks/site.yml
```
