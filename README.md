ddd
===

Docker Drupal Development

This will build your docker container
```
./build.sh
```
This will run your docker container
```
./run.sh
```
you can supply your own dush archive by uncommenting the following line in the Dockerfile

```
#COPY drush-archive.tar.gz /home/drush-archive.tar.gz
```
and simply place a drush tarball in the current directory named drush-archive (if you want to change the name you need to do so in start.sh as well)

to enter a shell in your new installation use nsenter:
https://github.com/jpetazzo/nsenter

or more modernly:

docker exec -i -t CONTAINER_ID /bin/bash

e.g. if this is the only container running on your laptop 
```
docker-enter `docker ps -q`
```
