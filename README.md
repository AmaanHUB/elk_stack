# ELK (Elasticsearch-Logstash-Kibana) Stack Project

## Prerequisites
* Vagrant
* VirtualBox (you are welcome to use Libvirt etc if the boxes are compatible)
* Ansible

### Optional Prerequisites
* AWS Account with a decent amount of credit on it
* Packer
* Terraform

## Introduction

**NOTE THAT THIS IS A MINIMUM VIABLE PRODUCT**
For a job interview process, I'd been given a task that revolves around the ELK stack. That main objectives of this task were:
* Deploy an ELK stack to a Linux system
* Have some logs appear on Kibana

I've done this in a couple of ways. Primarily I wanted to get this done on AWS, though the requirements for running the full ELK stack on an instance were outside of the purview of the free tier, thus I stuck to running it locally in a VM. This would also be much quicker with tearing it up and down before I had automated the full setup process.

## Vagrant and Virtual Machines (VMs)

Vagrant is an easy way to create and destroy containers quickly. The VM is configured in the `Vagrantfile` which is explained below:

* This section installs the `vagrant-hostsupdater` plugin, which modifies the `/etc/hosts` file and associates a url to the IP address of the VM

```ruby
# Install required plugins
required_plugins = ["vagrant-hostsupdater"]
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end
```
* This section is rather self-explanatory, with it choosing the 'base image' for the VM (Ubuntu 20.04 LTS in this case), forwarding some ports, adding 'elk.local' to the `/etc/hosts` file etc:

```ruby
Vagrant.configure("2") do |config|
  config.vm.define "elk" do |elk|
    elk.vm.box = "ubuntu/focal64"
    elk.vm.network "private_network", ip: "192.168.56.10"
    elk.hostsupdater.aliases = ["elk.local"]
    # elasticsearch
    elk.vm.network "forwarded_port", guest: 9200, host: 9200
    # kibana
    elk.vm.network "forwarded_port", guest: 5601, host: 5601
    # logstash
    elk.vm.network "forwarded_port", guest: 5044, host: 5044
```

* This calls the ansible playbook and tells it to run with the `-v` flag:
```ruby
    elk.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "provisioning/elk_installation.yaml"
	end
```

* Configuring virtualbox is done in this section, and I found that I had to have the memory above '4098' as it kept freezing during the build process:
```ruby
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "6144"
	end
```

## Ansible Provisioning

## AWS
**This hasn't been tested as I don't have an AWS account with money on it**
* something extra would be the inclusion of installing metricbeats on webnodes
* install and setup filebeats on the webnodes too,
### Packer
### Terraform

## Iteration
* [ ] Separate the Vagrantfile to create two machines to be closer to the end product on AWS
	* [ ] (one with ELK stack and one with just beats)
* [ ] Split the main playbook into 4, with a main one calling the ones that set up the parts of the stack. Easier maintenance
* [ ] Try and see if Kibana lets you set up filters without using the dashboards
* [ ] AWS Account To Run Packer/Terraform
* [ ] Terraform:
	* [ ] NACLs instantiated
	* [ ] IAM profiles
	* [ ] Cloudwatch and VPC Endpoint for logging
	* [ ] Generate SSL certificate with AWS Certificate Manager for usage in target groups and redirection
	* [ ] Modularise everything to prevent repeating code
* [ ] Authentication for ELK
	* [ ] TLS
	* [ ] Figure out how to use Ansible to set up a password for Elastic

