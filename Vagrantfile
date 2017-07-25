# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'

settings = YAML.load_file('settings.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.network :private_network, ip: settings['ip']

    config.vm.provider :virtualbox do |vb|
        vb.memory = "1024"
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--usb", "off"]
        vb.customize ["modifyvm", :id, "--usbehci", "off"]
        vb.customize ["modifyvm", :id, "--uartmode1", "disconnected" ]
    end

    if settings.include? "folders"
        settings["folders"].each do |folder|
            config.vm.synced_folder folder["map"], folder["to"], :owner => "ubuntu", :group => "www-data", mount_options: ["dmode=775,fmode=775"]
        end
    end

    config.vm.provision :shell, :args => [settings['mysql_user'] ||= "user"], path: "scripts/provision.sh"

    if settings.include? "sites"
        settings["sites"].each do |site|
            if site.include? "aliases"
                aliases = "("
                site["aliases"].each do |a|
                    aliases += " [" + a["map"] + "]=" + a["to"]
                end
                aliases += " )"
            end
            config.vm.provision :shell, :args => [site["map"], site["to"], aliases ||= ""], path: "scripts/sites.sh"
        end
    end

    if settings.has_key?("pyafipws") && settings["pyafipws"]
        config.vm.provision :shell, path: "scripts/pyafipws.sh"
    end

    config.hostsupdater.aliases = settings["sites"].map { |site| site["map"] }
end
