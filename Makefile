.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs ps prod temp ddd

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container
	@echo ""   2. make build     - build docker container
	@echo ""   3. make clean     - kill and remove docker container
	@echo ""   4. make enter     - execute an interactive bash in docker container
	@echo ""   3. make logs      - follow the logs of docker container

build: NAME TAG builddocker

# run a  container that requires mysql temporarily
temp: MYSQL_DB MYSQL_USER MYSQL_PASS IP PORT  build mysqltemp runmysqltemp ddd ps

# run a  container that requires mysql in production with persistent data
# HINT: use the grabmysqldatadir recipe to grab the data directory automatically from the above runmysqltemp
prod: IP PORT APACHE_DATADIR MYSQL_DATADIR MYSQL_PASS mysqlcid runprod ddd ps

pull:
	@docker pull joshuacox/ddd

ddd:
	@cat ddd.txt

ps:
	@docker ps | grep ddd

runmysqltemp: .net
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval NET := $(shell cat .net))
	$(eval TAG := $(shell cat TAG))
	$(eval IP := $(shell cat IP))
	$(eval PORT := $(shell cat PORT))
	chmod 777 $(TMP)
	docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-d \
	--network $(NET) \
	--network-alias mysqltemp \
	--publish=$(IP):$(PORT):80 \
	-v /var/run/docker.sock:/run/docker.sock \
	-v $(shell which docker):/bin/docker \
	-t $(TAG)

runprod: .net
	$(eval APACHE_DATADIR := $(shell cat APACHE_DATADIR))
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval NET := $(shell cat .net))
	$(eval TAG := $(shell cat TAG))
	$(eval IP := $(shell cat IP))
	$(eval PORT := $(shell cat PORT))
	chmod 777 $(TMP)
	docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-d \
	--publish=$(IP):$(PORT):80 \
	--network $(NET) \
	--network-alias ddd \
	-v /var/run/docker.sock:/run/docker.sock \
	-v $(APACHE_DATADIR):/var/www/html \
	-v $(shell which docker):/bin/docker \
	-t $(TAG)

builddocker:
	docker build -t `cat TAG` .

kill:
	-@docker kill `cat cid`

rm-image:
	-@docker rm `cat cid`
	-@rm cid

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

NETWORK: .net
	$(eval NET := $(shell cat .net))
	docker network create $(NET)

.net:
	@while [ -z "$$NET" ]; do \
		read -r -p "Enter the name of the network you wish to associate with this container [NET]: " NET; echo "$$NET">>.net; docker network create $$NET && cat .net; \
	done ;

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

TAG:
	@while [ -z "$$TAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container [TAG]: " TAG; echo "$$TAG">>TAG; cat TAG; \
	done ;

# MYSQL additions
# use these to generate a mysql container that may or may not be persistent

mysqlcid: .net
	$(eval MYSQL_DATADIR := $(shell cat MYSQL_DATADIR))
	$(eval NAME := $(shell cat NAME))
	$(eval NET := $(shell cat .net))
	docker run \
	--cidfile="mysqlcid" \
	--network $(NET) \
	--name $(NAME)-mysql \
	-e MYSQL_ROOT_PASSWORD=`cat MYSQL_PASS` \
	-d \
	--network ddd \
	--network-alias mysql \
	-v $(MYSQL_DATADIR):/var/lib/mysql \
	mysql:5.7

rmmysql: mysqlcid-rmkill

mysqlcid-rmkill:
	-@docker kill `cat mysqlcid`
	-@docker rm `cat mysqlcid`
	-@rm mysqlcid

# This one is ephemeral and will not persist data
mysqltemp:
	$(eval NAME := $(shell cat NAME))
	$(eval MYSQL_USER := $(shell cat MYSQL_USER))
	$(eval MYSQL_PASS := $(shell cat MYSQL_PASS))
	$(eval MYSQL_DB := $(shell cat MYSQL_DB))
	docker run \
	--cidfile="mysqltemp" \
	--name $(NAME)-mysqltemp \
	-e MYSQL_ROOT_PASSWORD=$(MYSQL_PASS) \
	-e MYSQL_PASSWORD=$(MYSQL_PASS) \
	-e MYSQL_USER=$(MYSQL_USER) \
	-e MYSQL_DATABASE=$(MYSQL_DB) \
	-d \
	mysql:5.7

rmmysqltemp: mysqltemp-rmkill

mysqltemp-rmkill:
	-@docker kill `cat mysqltemp`
	-@docker rm `cat mysqltemp`
	-@rm mysqltemp

rmall: rm rmmysqltemp rmmysql

grab: grabapachedir grabmysqldatadir

# sudo on the cp as I am getting errors on btrfs storage driven docker systems

grabmysqldatadir:
	-mkdir -p datadir
	sudo docker cp `cat mysqltemp`:/var/lib/mysql datadir/
	echo `pwd`/datadir/mysql > MYSQL_DATADIR
	-@sudo chown -R $(user). datadir/mysql

grabapachedir:
	-mkdir -p datadir
	sudo docker cp `cat cid`:/var/www/html datadir/
	echo `pwd`/datadir/html > APACHE_DATADIR
	-@sudo chown -R www-data. datadir/html

#	sudo chown -R $(user). datadir/html

APACHE_DATADIR:
	@while [ -z "$$APACHE_DATADIR" ]; do \
		read -r -p "Enter the destination of the Apache data directory you wish to associate with this container [APACHE_DATADIR]: " APACHE_DATADIR; echo "$$APACHE_DATADIR">>APACHE_DATADIR; cat APACHE_DATADIR; \
	done ;

MYSQL_DATADIR:
	@while [ -z "$$MYSQL_DATADIR" ]; do \
		read -r -p "Enter the destination of the MySQL data directory you wish to associate with this container [MYSQL_DATADIR]: " MYSQL_DATADIR; echo "$$MYSQL_DATADIR">>MYSQL_DATADIR; cat MYSQL_DATADIR; \
	done ;

MYSQL_PASS:
	@while [ -z "$$MYSQL_PASS" ]; do \
		read -r -p "Enter the MySQL password you wish to associate with this container [MYSQL_PASS]: " MYSQL_PASS; echo "$$MYSQL_PASS">>MYSQL_PASS; cat MYSQL_PASS; \
	done ;

MYSQL_USER:
	@while [ -z "$$MYSQL_USER" ]; do \
		read -r -p "Enter the MySQL user you wish to associate with this container [MYSQL_USER]: " MYSQL_USER; echo "$$MYSQL_USER">>MYSQL_USER; cat MYSQL_USER; \
	done ;

MYSQL_DB:
	@while [ -z "$$MYSQL_DB" ]; do \
		read -r -p "Enter the MySQL database you wish to associate with this container [MYSQL_DB]: " MYSQL_DB; echo "$$MYSQL_DB">>MYSQL_DB; cat MYSQL_DB; \
	done ;

PORT:
	@while [ -z "$$PORT" ]; do \
		read -r -p "Enter the port you wish to associate with this container [PORT]: " PORT; echo "$$PORT">>PORT; cat PORT; \
	done ;

IP:
	@while [ -z "$$IP" ]; do \
		read -r -p "Enter the IP you wish to associate with this redmine [IP]: " IP; echo "$$IP">>IP; cat IP; \
	done ;

next: grab rmall prod
