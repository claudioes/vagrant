#!/bin/bash

function package_exists() {
    dpkg -l "$1" &> /dev/null
}

SERVER_NAME=$1
ROOT_FOLDER=$2
MYSQL_USER=$3

sudo apt-get update
sudo apt-get -y upgrade

# Apache

if ! package_exists 'apache2' ; then
	sudo apt-get install -y apache2
fi

# MySQL

if ! package_exists 'mariadb-server' ; then
	sudo apt-get install -y mariadb-server mariadb-client
fi

# PHP

if ! package_exists 'php' ; then
	sudo apt-get install -y php php-bcmath php-bz2 php-cli php-curl php-intl php-json php-mbstring php-opcache php-soap php-sqlite3 php-xml php-xsl php-zip php-mysql php-imagick php-gd libapache2-mod-php
fi

# Python 3 (pip)

if ! package_exists 'python3' ; then
	sudo apt-get install -y python3-pip
fi

# Python 2.7 (para PyAfipWS)

if ! package_exists 'python' ; then
    sudo apt-get install -y python python-pip

	# Para compilar M2Crypto son necesarios los siguientes packages

	sudo apt-get install -y swig libssl-dev

	# Configuración de PyAfipWS

	# Clono el repositorio
	# git clone https://github.com/reingart/pyafipws.git

	# Creo un entorno virtual de Python 2.7
	# sudo apt-get install -y virtualenv
	# virtualenv pyafipenv
	# source pyafipenv/bin/activate -p python

	# Instalo los módulos necesarios
	# pip install -r pyafipws/requirements.txt
	# pip install httplib2==0.9.2
	# deactive

	# Creo y doy permisos apache sobre la carpeta Cache de PyAfipWs
	# mkdir pyafipws/cache
	# chown claudio:www-data pyafipws/cache
fi

# WKHtml

if [ ! -f /usr/bin/wkhtmltopdf ]; then
	sudo apt-get install libxrender1 fontconfig xvfb
	wget https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -P /tmp/
	cd /opt/
	sudo tar xf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
	sudo ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
fi

# LibreOffice
if ! package_exists 'libreoffice' ; then
	sudo apt-get install -y libreoffice-writer libreoffice-calc unoconv
fi

# ImageMagick

if ! package_exists 'imagemagick' ; then
	sudo apt-get install -y imagemagick
fi

# Composer

if [ ! -f /usr/local/bin/composer ]; then
	sudo apt-get install -y curl unzip
	sudo curl -sS https://getcomposer.org/installer -o composer-setup.php
	sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
fi

# Node

if ! package_exists 'nodejs' ; then
	sudo curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
	sudo bash nodesource_setup.sh
	sudo apt-get install -y nodejs build-essential
	sudo apt-get install -y npm
fi

# npm install gulp-cli -g # Gulp
# npm install --no-bin-links # Vagrant on top of Windows. You cannot use symlinks.

# Acceso remoto a MySQL

LINE="[mysqld]
bind-address = 0.0.0.0"
FILE="/etc/mysql/my.cnf"
sudo grep -q "$LINE" "$FILE" || echo "$LINE" | sudo tee --append "$FILE" > /dev/null

# Usuario con acceso remote a MySQL

sudo mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

sudo systemctl restart mysql

# Configuración de Apache

echo "<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>" > /etc/apache2/mods-enabled/dir.conf

a2enmod rewrite

# Habilito a Apache a escribir en var/www
# Necesario para unoconv ya que crea un directorio .config en esta carpeta

sudo chown -R www-data:www-data /var/www

# Reinicio Apache para que la configuración tome efecto

sudo systemctl restart apache2

sudo apt-get autoclean
sudo apt-get -f install
