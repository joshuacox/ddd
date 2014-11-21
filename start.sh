#!/bin/bash
if [ ! -f /var/www/sites/default/settings.php ]; then
  /etc/init.d/mysql stop
	/usr/bin/mysqld_safe --skip-grant-tables &
	sleep 10
	# Generate random passwords 
	DRUPAL_DB="drupal"
	MYSQL_PASSWORD=`pwgen -c -n -1 12`
	DRUPAL_PASSWORD=`pwgen -c -n -1 12`
	# This is so the passwords show up in logs.
	echo mysql root password: $MYSQL_PASSWORD
	echo drupal password: $DRUPAL_PASSWORD
	echo $MYSQL_PASSWORD > /mysql-root-pw.txt
	echo $DRUPAL_PASSWORD > /drupal-db-pw.txt
	#mysqladmin -u root password $MYSQL_PASSWORD
  mysql -h localhost -u root mysql -e "update user set Password=PASSWORD('$MYSQL_PASSWORD') WHERE User='root'"
  /etc/init.d/mysql stop
	/usr/bin/mysqld_safe &
	sleep 3
	mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE drupal; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
	mysql -uroot -p$MYSQL_PASSWORD -e "show grants for drupal@localhost;"
	sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
	a2enmod rewrite vhost_alias
	cd /var/www/
	drush site-install standard -y --account-name=admin --account-pass=admin --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal"
  # Have your own archive to restore from? comment the above and uncomment below
	#drush archive-restore --db-url="mysqli://drupal:${DRUPAL_PASSWORD}@localhost:3306/drupal" --overwrite --destination=/var/www/ /home/drush-archive.tar.gz
	killall mysqld
	sleep 10
fi
supervisord -n
