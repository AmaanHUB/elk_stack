# -*- mode: ruby -*-
# vi: set ft=ruby :
# Install required plugins
required_plugins = ["vagrant-hostsupdater"]
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
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

    # Run ansible playbook
    elk.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "provisioning/elk_installation.yaml"
   end

    end

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "6144"
  end
end
