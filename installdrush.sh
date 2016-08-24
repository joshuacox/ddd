# Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
php -r "readfile('http://files.drush.org/drush.phar');" > drush

# Test your install.
php drush core-status

# Rename to `drush` instead of `php drush.phar`. Destination can be anywhere on $PATH. 
chmod +x drush
mv drush /usr/local/bin/drush

# Enrich the bash startup file with completion and aliases.
drush init

# composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified';  } else { echo 'Installer corrupt'; unlink('composer-setup.php');  } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

rm -Rf /var/www/html
cd /var/www
drush dl drupal-8
mv drupal-8.* html
chown -R www-data. /var/www
