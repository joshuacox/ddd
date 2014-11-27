FROM debian:wheezy
MAINTAINER Josh Cox <josh 'at' webhosting.coop>

ENV DEBIAN_FRONTEND noninteractive

#oltorf proxy
#RUN echo 'Acquire::http::Proxy "http://65.67.51.187:3142";'>>/etc/apt/apt.conf
RUN apt-get -y update
RUN apt-get -y install python-software-properties curl build-essential libxml2-dev libxslt-dev git ruby1.9.1-dev ca-certificates sudo net-tools vim
#RUN apt-get -y update
RUN apt-get -y dist-upgrade

RUN echo "Installing Chef This may take a few minutes..."
RUN curl -L https://www.getchef.com/chef/install.sh | sudo bash
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN /opt/chef/embedded/bin/gem install berkshelf
RUN echo "Installing mysql now as the cookbook is failing This may take a few minutes..."

RUN echo "Installing berksfile..."
ADD ./Berksfile /Berksfile
ADD ./chef/roles /var/chef/roles
ADD ./chef/solo.rb /var/chef/solo.rb
ADD ./chef/solo.json /var/chef/solo.json

RUN echo "Installing berks This may take a few minutes..."
RUN cd / && /opt/chef/embedded/bin/berks vendor /var/chef/cookbooks
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
