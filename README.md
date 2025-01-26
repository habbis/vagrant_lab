# My Vagrant lab

I use this to test software and other development tasks.

By default it uses virtualbox, but i have added support for hyperv and vmware
workstation.


## installing vagrant

Here you can install [vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)

## Installing virtualbox.

Here you can install (virtualbox)[https://www.virtualbox.org/wiki/Downloads]


## Vagrant commands.

To setup autocomplete for vagrant cli.
```
vagrant autocomplete install
```

To setup vagrant vm cd to folder with a vagrantfile.


Starts and provisions the vagrant environment
```
vagrant up
```
start Vagrant server
```
vagrant serve
```

To login to the machine via ssh.
```
vagrant ssh server-name
```

To restarts vagrant machine, loads new Vagrantfile configuration
```
vagrant reload
```

To run the provisions steps only for the vagrant machine.
```
vagrant provision
```

To remove vagrant vm.
```
vagrant destroy -f
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
    subconfig.vm.network "private_network", ip: "192.168.56.10"
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "unode#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "unode#{i}"
      subconfig.vm.network "private_network", ip: "192.168.56.#{i + 10}"
    end
  end

    ####### Install Puppet Agent #######
    config.vm.provision "bootstrap",
      before: :all,
      type: "shell",
      path: "../bootstrap.sh"

    ####### Provision #######
    config.vm.provision :puppet do |puppet|
        puppet.module_path = "../site"
        puppet.options = "--verbose --debug"
      end
  end
```

So BOX_IMAGE here you can set your image and NODE_COUNT is where how many
vm you want. Zero means that only the master node will be provisioned.

Here is the master node ip addr.

```
subconfig.vm.network "private_network", ip: "192.168.56.10"
```


The node ip addr is here and it goes from how many vm spesified in
NODE_COUNT  .

```
 subconfig.vm.network "private_network", ip: "192.168.56.#{i + 10}"
```

I am using puppet/openvox to setup the vm and bootstrap shell script to install puppet-agent/openvox-agent.

The puppet moduel is under site folder.
