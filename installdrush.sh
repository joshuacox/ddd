# Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
wget http://files.drush.org/drush.phar

# Test your install.
php drush.phar core-status

# Rename to `drush` instead of `php drush.phar`. Destination can be anywhere on $PATH. 
chmod +x drush.phar
mv drush.phar /usr/local/bin/drush

# Enrich the bash startup file with completion and aliases.
drush init

rm -Rf /var/www/html
cd /var/www
drush dl drupal-8
mv drupal-8.0.0 html;
chown -R www-data. /var/www
