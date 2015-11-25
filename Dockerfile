FROM drupal:8

RUN apt-get update
RUN apt-get install -y wget mysql-client
RUN rm -rf /var/lib/apt/lists/*

COPY installdrush.sh /root/installdrush.sh
RUN /bin/bash /root/installdrush.sh
RUN chsh -s /bin/bash www-data
