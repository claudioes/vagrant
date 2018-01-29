#!/bin/bash

function package_exists() {
    dpkg -l "$1" &> /dev/null
}

MYSQL_USER=$1

apt-get update
apt-get -y upgrade

# Apache

if ! package_exists 'apache2' ; then
    apt-get install -y apache2
fi

# MySQL

if ! package_exists 'mariadb-server' ; then
    apt-get install -y mariadb-server mariadb-client
fi

# PHP

if ! package_exists 'php' ; then
    apt-get install -y php php-bcmath php-bz2 php-cli php-curl php-intl php-json php-mbstring php-opcache php-soap php-sqlite3 php-xml php-xsl php-zip php-mysql php-imagick php-gd libapache2-mod-php
fi

# Python 3 (pip)

if ! package_exists 'python3' ; then
    apt-get install -y python3-pip
fi

# WKHtml

if [ ! -f /usr/bin/wkhtmltopdf ]; then
    apt-get install libxrender1 fontconfig xvfb
    wget https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -P /tmp/
    cd /opt/
    tar xf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
    ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
fi

# LibreOffice
if ! package_exists 'libreoffice' ; then
    apt-get install -y libreoffice-writer libreoffice-calc unoconv
fi

# ImageMagick

if ! package_exists 'imagemagick' ; then
    apt-get install -y imagemagick
fi

# Composer

if [ ! -f /usr/local/bin/composer ]; then
    apt-get install -y curl unzip
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
fi

# Node

if ! package_exists 'nodejs' ; then
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
    bash nodesource_setup.sh
    apt-get install -y nodejs build-essential
    apt-get install -y npm
fi

# npm install gulp-cli -g # Gulp
# npm install --no-bin-links # Vagrant on top of Windows. You cannot use symlinks.

# Acceso remoto a MySQL

LINE="[mysqld]
bind-address = 0.0.0.0"
FILE="/etc/mysql/my.cnf"
grep -q -F "$LINE" "$FILE" || echo "$LINE" | tee --append "$FILE" > /dev/null

# Usuario con acceso remote a MySQL

mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"

systemctl restart mysql

# Configuración de Apache

echo "<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>" > /etc/apache2/mods-enabled/dir.conf

a2enmod rewrite

# Habilito a Apache a escribir en var/www
# Necesario para unoconv ya que crea un directorio .config en esta carpeta

chown -R www-data:www-data /var/www

# Elimino los Hosts virtuales creados anteriormente

rm /etc/apache2/sites-available/*
rm /etc/apache2/sites-enabled/*

# Reinicio Apache para que la configuración tome efecto

service apache2 reload

apt-get autoclean
apt-get -f install

npm install gulp-cli -g