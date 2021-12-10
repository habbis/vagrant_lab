# My Vagrant lab 

I use this to test ansible modules and other development tasks.

By default it uses virtualbox, but i have added support for hyperv and vmware
workstation.

## Installing virtualbox.

Ubuntu

```
sudo apt-get install virtualbox
```

Installing VirtualBox Extension Pack.

```
sudo apt-get install virtualbox—ext–pack
```

debian

Import gpg keys.

```
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

```
Add repo.

```
sudo apt install software-properties-common
sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

```

Install.

```
sudo apt update && sudo apt install virtualbox-6.0

```

Installing VirtualBox Extension Pack.

```
wget https://download.virtualbox.org/virtualbox/6.0.10/Oracle_VM_VirtualBox_Extension_Pack-6.0.10.vbox-extpack
```

```
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.0.10.vbox-extpack
```

Fedora.

Setup repo
```
sudo dnf -y install wget
wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
sudo mv virtualbox.repo /etc/yum.repos.d/virtualbox.repo
```

Install.

```
sudo dnf install -y gcc binutils make glibc-devel patch libgomp glibc-headers  kernel-headers kernel-devel-`uname -r` dkms
sudo dnf install -y VirtualBox-6.1
```

Add udd user to virtualbox group.

```
sudo usermod -a -G vboxusers ${USER}
```

Configure virtualbox drivers.

```
sudo /usr/lib/virtualbox/vboxdrv.sh setup
```

Installing VirtualBox Extension Pack.

```
wget https://download.virtualbox.org/virtualbox/6.1.28/Oracle_VM_VirtualBox_Extension_Pack-6.1.28.vbox-extpack
```

You may need to do this.

```
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.28.vbox-extpack

```

Macos 

```
brew install virtualbox

```

## Setup Vagrant 

ubuntu/debian

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update && sudo apt-get install vagrant

```

Centos/RHEL

```
sudo yum install -y yum-utils

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

sudo yum -y install vagrant

```

Fedora

```
sudo dnf install -y dnf-plugins-core

sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

sudo dnf -y install vagrant
```

Macos/linux homebrew

```
brew install vagrant
```

You need ansible since its used with vagrant.

To install newest ansible on linux you need pip.

Linux

```
python3 -m pip install --user ansible

```

Macos

```
brew install ansible
```

How to use with examples.

To to the linux distro you want to use.

```

cd ubuntu20.04

```

To provisjon a vm.

```
vagrant up

```

After it finished you can list status.

```
vagrant status
```

To ssh into you van use this command.

```
vagrant ssh yourvm
```


The vagrant file looks like this.

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
BOX_IMAGE = "bento/ubuntu-20.04"
NODE_COUNT = 0

Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox"
    #config.vm.provider "vmware_desktop"
    #config.vm.provider "hyperv"
    config.vm.define "umaster" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "umaster"
    subconfig.vm.network "private_network", ip: "10.60.1.10"
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "unode#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "unode#{i}"
      subconfig.vm.network "private_network", ip: "10.60.1.#{i + 10}"
    end
  end

  # Install avahi on all machines
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "server-lite.yml"
  end
end


```

So BOX_IMAGE here you can set your image and NODE_COUNT is where how many
vm you want. Zero means that only the master node will be provisioned.

Here is the master node ip addr.

```
subconfig.vm.network "private_network", ip: "10.60.1.10"
```


The node ip addr is here and it goes from how many vm spesified in
NODE_COUNT  .

```
 subconfig.vm.network "private_network", ip: "10.60.1.#{i + 10}"
```

And ansible is set to setup the vm with the playbook
server-lite.yml

```
 config.vm.provision "ansible" do |ansible|
 ansible.playbook = "server-lite.yml"

```

The ansible playbook looks like this.

Change this line you your gitlab or github username this task 
will gather your public ssh key.

```
key: https://github.com/habbis.keys

```

server-lite.yml is symlinked to all folders except those with the name docker.

```
---
- hosts: all
  #remote_user: root
  remote_user: vagrant
  #remote_user: user
  become: yes
  become_method: sudo

  tasks:
  - name: upgrade all packages
    package:
      name: "*"
      state: latest

  - name: Install packages ubuntu and debian
    package:
      name:
        #- cockpit
        - curl
        - wget
        - python
        - python3
        - python3-pip
        - git
        - vim
        - apt-utils
        - lvm2
      state: present
    ignore_errors: yes

  - name: add group admins for nopasswd sudo
    group:
      name: admins
      state: present


  - name: Install packages centos7 and RHEL7
    package:
      name:
        - cockpit
        #- podman
        - curl
        - wget
        - python2
        - python3
        - python3-pip
        - git
        - vim
        - yum-utils
        - device-mapper-persistent-data
        - lvm2
        - epel-release
        - sudo
        - bash-completion
        #- centos-release-scl-rh
        #- centos-release-scl
      state: present
    ignore_errors: yes

  - name: sudoers file
    get_url:
      url: https://raw.githubusercontent.com/habbis/sudoers/master/admins
      dest: /etc/sudoers.d/
      mode: '0440'

  - name: Download sshd_config from git repo
    get_url:
      url: https://gitlab.com/habbis/openssh_config/raw/master/sshd_config
      dest: /etc/ssh/
      mode: '0744'

  #- name: Create group for docker
    #group:
      #name: docker
      #state: absent

  - name: add right sftp server for rhel/centos in sshd_config
    lineinfile:
      path: /etc/ssh/sshd_config
      regexp: '/usr/lib/openssh/sftp-server'
      line: "Subsystem  sftp /usr/libexec/openssh/sftp-server"
    when: ansible_pkg_mgr == "yum"

  - name: add user called user with sudo right
    user:
      name: ansible
      shell: /bin/bash
      groups: admins
      append: yes

  - name: set authorized keys from github to users
    authorized_key:
      user: "{{ item }}"
      state: present
      key: https://github.com/habbis.keys
    loop:
      - root
      - ansible
    ignore_errors: yes


  - name: reload sshd
    service:
      name: sshd
      state: reloaded

      #- name: enable cockpit systemd service
      #firewalld:
      #service: cockpit
      #permanent: yes
      #state: enabled



```
