SITE=$1
FOLDER=$2

echo "<VirtualHost *:80>
    ServerName $SITE
    ServerAdmin webmaster@localhost
    DocumentRoot $FOLDER

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory $FOLDER>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$SITE.conf

sudo a2ensite $SITE
sudo systemctl reload apache2
