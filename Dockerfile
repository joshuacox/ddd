FROM drupal:7

RUN apt-get update
RUN apt-get install -y wget mysql-client git \
 && rm -rf /var/lib/apt/lists/*

COPY installcomposer.sh /root/installcomposer.sh
COPY installdrush.sh /root/installdrush.sh
RUN /root/installcomposer.sh
RUN chsh -s /bin/bash www-data \
 && mkdir -p /var/www/.composer/cache \
 && chown -R www-data. /var/www/.composer \
 && chown -R www-data. /var/www/html \
 && /root/installdrush.sh
WORKDIR  /var/www/html
USER www-data
RUN composer require drush/drush
USER root
