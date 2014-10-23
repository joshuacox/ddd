FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive

ADD ./ddd.txt /ddd.txt
RUN cat "/ddd.txt"
RUN apt-get -y update
RUN apt-get -y install python-software-properties curl build-essential libxml2-dev libxslt-dev git ruby1.9.1-dev ca-certificates sudo
RUN apt-get -y update
RUN echo "Installing Chef This may take a few minutes..."
RUN curl -L https://www.getchef.com/chef/install.sh | sudo bash
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN /opt/chef/embedded/bin/gem install berkshelf
RUN echo "Installing mysql now as the cookbook is failing This may take a few minutes...."
RUN apt-get -y install mysql-server

RUN echo "Installing berksfile"
ADD ./Berksfile /Berksfile
ADD ./chef/roles /var/chef/roles
ADD ./chef/solo.rb /var/chef/solo.rb
ADD ./chef/solo.json /var/chef/solo.json

RUN echo "Installing berks This may take a few minutes....."
RUN cd / && /opt/chef/embedded/bin/berks vendor /var/chef/cookbooks
RUN chef-solo -c /var/chef/solo.rb -j /var/chef/solo.json
