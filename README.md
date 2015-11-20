ddd
===

Docker Drupal Development

Build a container from scratch, this will prompt you for a few details like a Mysql password (which will be stored locally)
```
make temp
```
and you should be able to install a drupal site using the password you just gave, mysqluser=drupal database=drupal mysqlhost=mysql

to grab the data directories from apache and mysql do:
```
make grab
```

then you should be able to:
```
make prod
```

and run a persistent local drupal 8 install, if you want to try drupal 7 change out the 8 for a 7 in the FROM line of the Dockerfile
