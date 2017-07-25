#!/bin/bash

function package_exists() {
    dpkg -l "$1" &> /dev/null
}

if ! package_exists 'python' ; then
    apt-get install -y python python-pip
fi

	# Para compilar M2Crypto son necesarios los siguientes packages
if ! package_exists 'swig' ; then
	apt-get install -y swig
fi

if ! package_exists 'libssl-dev' ; then
	apt-get install -y libssl-dev
fi

if ! package_exists 'virtualenv' ; then
    sudo apt-get install -y virtualenv
fi

mkdir -p /home/ubuntu/afip
cd /home/ubuntu/afip
git clone https://github.com/reingart/pyafipws.git
virtualenv env
source env/bin/activate -p python
pip install -r pyafipws/requirements.txt
pip install httplib2==0.9.2
deactive
mkdir pyafipws/cache
chown -R ubuntu:www-data /home/ubuntu/afip
