#!/bin/bash

function package_exists() {
    dpkg -l "$1" &> /dev/null
}

# PyAfipWs solo funciona con Python 2 :(

if ! which 'python' &> /dev/null ; then
    apt-get install -y python python-pip
fi

# Para compilar M2Crypto son necesarios swig y libssl-dev

if ! package_exists 'swig' ; then
	apt-get install -y swig
fi

if ! package_exists 'libssl-dev' ; then
	apt-get install -y libssl-dev
fi

# Entorno virtual para no "contaminar" el espacio global

if ! package_exists 'virtualenv' ; then
    apt-get install -y virtualenv
fi

folder="/home/ubuntu/pyafipws"
env="/home/ubuntu/pyafipenv"

if [ ! -d $folder ]; then
    git clone https://github.com/reingart/pyafipws.git $folder

    if [ -d $folder ]; then
        chown -R ubuntu:ubuntu $folder
        mkdir "${folder}/cache"
        chmod 775 "${folder}/cache"
        chown ubuntu:www-data "${folder}/cache"
    else
        echo "No se pudo clonar el repositorio de PyAfipWS"
    fi
fi

if [ ! -d $env ]; then
    virtualenv $env -p python

    if [ -d $env ]; then
        source "$env/bin/activate"
        pip install -r "${folder}/requirements.txt"
        pip install httplib2==0.9.2
        deactivate
        chown -R ubuntu:ubuntu $env
    else
        echo "No se pudo crear el entorno virtual $env"
    fi
fi
