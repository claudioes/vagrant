# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

settings = YAML.load_file('settings.yaml')

server_ip = settings['ip']
server_hostname = settings['hostname']
local_folder = settings['local_folder']
root_folder = settings['root_folder']
mysql_user = settings['mysql_user']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network :private_network, ip: server_ip
  config.vm.synced_folder local_folder, root_folder, :owner => "ubuntu", :group => "www-data", mount_options: ["dmode=775,fmode=664"]

  config.vm.provider :virtualbox do |vb|
    vb.memory = "1024"
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--usb", "off"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
  end

  config.vm.provision :shell, :args => [server_hostname, root_folder, mysql_user], path: "scripts/provision.sh"

  settings['alias'].each do |a|
    config.vm.provision :shell, :args => [a['name'], site['folder']], path: "scripts/alias.sh"
  end

  settings['sites'].each do |s|
    config.vm.provision :shell, :args => [s['name'], s['folder']], path: "scripts/sites.sh"
  end
  
  config.hostsupdater.aliases = settings['sites'].map { |site| site['map'] }
end
