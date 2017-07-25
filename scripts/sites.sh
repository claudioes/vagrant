site=$1
folder=$2

declare -A aliases=$3
aliasesTXT=""
if [ -n "$3" ]; then
    for element in "${!aliases[@]}"
    do
        aliasesTXT="${aliasesTXT}
            Alias /${element} ${aliases[$element]}
                <Directory \"${aliases[$element]}\">
                        Options Indexes FollowSymLinks
                        AllowOverride All
                        Require all granted
                </Directory>
        "
    done
fi

echo "<VirtualHost *:80>
    ServerName ${site}
    ServerAdmin webmaster@localhost
    DocumentRoot ${folder}

    ErrorLog \${APACHE_LOG_DIR}/${site}-error.log
    CustomLog \${APACHE_LOG_DIR}/${site}-access.log combined

    <Directory ${folder}>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ${aliasesTXT}
</VirtualHost>" > /etc/apache2/sites-available/$site.conf

a2ensite $site
service apache2 reload
