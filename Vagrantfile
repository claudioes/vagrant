# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

confDir = File.expand_path(File.dirname(__FILE__))

settings = YAML.load_file(confDir + '/settings.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/xenial64"

    config.vm.provider :virtualbox do |vb|
        vb.memory = settings["memory"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--usb", "off"]
        vb.customize ["modifyvm", :id, "--usbehci", "off"]
        vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
        vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
    end

    # Private Network IP

    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

    # Additional Networks

    if settings.has_key?("networks")
        settings["networks"].each do |network|
            config.vm.network network["type"] + "_network", ip: network["ip"], bridge: network["bridge"] ||= nil
        end
    end

    # Folders

    if settings.has_key?("folders")
        settings["folders"].each do |folder|
            config.vm.synced_folder folder["map"], folder["to"], :owner => "vagrant", :group => "www-data", mount_options: ["dmode=775,fmode=775"]
        end
    end

    # Provisions

    config.vm.provision :shell, :args => [settings['mysql_user'] ||= "user"], path: "scripts/provision.sh"

    # Sites & Aliases

    if settings.has_key?("sites")
        settings["sites"].each do |site|
            if site.has_key?("aliases")
                aliases = "("
                site["aliases"].each do |a|
                    aliases += " [" + a["map"] + "]=" + a["to"]
                end
                aliases += " )"
            end
            config.vm.provision :shell, :args => [site["map"], site["to"], aliases ||= ""], path: "scripts/sites.sh"
        end
    end

    # PyAfipWS

    if settings.has_key?("pyafipws") && settings["pyafipws"]
        config.vm.provision :shell, path: "scripts/pyafipws.sh"
    end

    # Hosts Updater

    config.hostsupdater.aliases = settings["sites"].map { |site| site["map"] }
end
