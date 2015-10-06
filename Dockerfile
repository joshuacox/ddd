FROM joshuacox/docker-chef-solo:wheezy
MAINTAINER Josh Cox <josh 'at' webhosting.coop>

ENV DEBIAN_FRONTEND noninteractive
ENV DDD_updated 20151006
RUN apt-get update
RUN apt-get -y install mysql-server

# This block became necessary with the new chef 12
RUN apt-get -y install locales
# RUN echo 'en_US.ISO-8859-15 ISO-8859-15'>>/etc/locale.gen
# RUN echo 'en_US ISO-8859-1'>>/etc/locale.gen
RUN echo 'en_US.UTF-8 UTF-8'>>/etc/locale.gen
RUN locale-gen
ENV LANG en_US.UTF-8

RUN echo "Installing berksfile..."
ADD ./Berksfile /Berksfile
ADD ./chef/roles /var/chef/roles
ADD ./chef/solo.rb /var/chef/solo.rb
ADD ./chef/solo.json /var/chef/solo.json

RUN echo "Installing berks This may take a few minutes..."
RUN cd / && /opt/chef/embedded/bin/berks vendor /var/chef/cookbooks
RUN echo "Installing chef This may take a few minutes..."
RUN chef-solo -c /var/chef/solo.rb -j /var/chef/solo.json

#### DDD
RUN apt-get -y install mysql-server
RUN apt-get -y install pwgen python-setuptools php5-mysql php5-gd php5-curl php5-memcache memcached
RUN apt-get autoclean

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl  

# Make mysql listen on the outside
RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf

ADD ./ddd.txt /ddd.txt
ADD ./README.md /README.md
ADD ./LICENSE /LICENSE
RUN cat "/LICENSE" "/README.md" "/ddd.txt"

# Retrieve drupal or supply your own not both
RUN rm -rf /var/www/ ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/
# Or supply your own, modify start.sh accordingly (look for the comment)
#COPY drush-archive.tar.gz /home/drush-archive.tar.gz

RUN easy_install supervisor
RUN echo "foo...."
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

RUN chmod 755 /start.sh /etc/apache2/foreground.sh
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
