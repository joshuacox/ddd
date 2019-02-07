#!/bin/sh
TMP=$(mktemp -d)
cd $TMP
wget -q -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar
# Rename to `drush` instead of `php drush.phar`. Destination can be anywhere on $PATH. 
chmod +x drush.phar
mv drush.phar /usr/local/bin/drush

# Enrich the bash startup file with completion and aliases.
#drush init

#rm -Rf /var/www/html
#cd /var/www
#drush dl drupal-8
#mv drupal-8.* html
#chown -R www-data. /var/www
