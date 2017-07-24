#!/bin/bash

ALIAS=$1
FOLDER=$2

echo "Alias /$ALIAS $FOLDER
	<Directory \"$FOLDER\">
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>
" > /etc/apache2/conf-available/$ALIAS.conf

sudo a2enconf $ALIAS
sudo systemctl reload apache2
