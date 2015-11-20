FROM drupal:8

RUN apt-get update
RUN apt-get install -y wget

COPY installdrush.sh /root/installdrush.sh
RUN /bin/bash /root/installdrush.sh
