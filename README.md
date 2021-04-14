# Project to deploy GLPI with docker

![Docker Pulls](https://img.shields.io/docker/pulls/diouxx/glpi) ![Docker Stars](https://img.shields.io/docker/stars/diouxx/glpi) [![](https://images.microbadger.com/badges/image/diouxx/glpi.svg)](http://microbadger.com/images/diouxx/glpi "Get your own image badge on microbadger.com") ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/diouxx/glpi)

# Table of Contents
- [Project to deploy GLPI with docker](#project-to-deploy-glpi-with-docker)
- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Deploy with CLI](#deploy-with-cli)
  - [Deploy GLPI](#deploy-glpi)
  - [Deploy GLPI with existing database](#deploy-glpi-with-existing-database)
  - [Deploy GLPI with database and persistence container data](#deploy-glpi-with-database-and-persistence-container-data)
  - [Deploy a specific release of GLPI](#deploy-a-specific-release-of-glpi)
- [Deploy with docker-compose](#deploy-with-docker-compose)
  - [Deploy without persistence data ( for quickly test )](#deploy-without-persistence-data--for-quickly-test)
  - [Deploy with persistence data](#deploy-with-persistence-data)
    - [mysql.env](#mysqlenv)
    - [docker-compose .yml](#docker-compose-yml)
- [Environnment variables](#environnment-variables)
  - [TIMEZONE](#timezone)

# Introduction

Install and run an GLPI instance with docker.

# Rebuild
```sh
docker build . --tag woodswolf/glpi:9.5.5
docker image save -o glpi.20210414.tar.gz woodswolf/glpi:9.5.5
docker push woodswolf/glpi:9.5.5
docker pull mariadb:focal
docker image save -o mariadb.20210414.tar.gz mariadb:focal
curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose



```

# Adminstration

## Creating database dumps
```sh
docker exec some-mariadb sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
```
# Deploy with CLI

## Deploy GLPI 
```sh
docker run --name mysql -e MYSQL_ROOT_PASSWORD=diouxx -e MYSQL_DATABASE=glpidb -e MYSQL_USER=glpi_user -e MYSQL_PASSWORD=glpi -d mysql:5.7.23
docker run --name glpi --link mysql:mysql -p 80:80 -d diouxx/glpi
```

## Restoring data from dump files
```sh
docker exec -i some-mariadb sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < /some/path/on/your/host/all-databases.sql
```

## Deploy GLPI with existing database
```sh
docker run --name glpi --link yourdatabase:mysql -p 80:80 -d diouxx/glpi
```

## Deploy GLPI with database and persistence data

For an usage on production environnement or daily usage, it's recommanded to use container with volumes to persistent data.

* First, create MySQL container with volume

```sh
docker run --name mysql -e MYSQL_ROOT_PASSWORD=diouxx -e MYSQL_DATABASE=glpidb -e MYSQL_USER=glpi_user -e MYSQL_PASSWORD=glpi --volume /var/lib/mysql:/var/lib/mysql -d mysql:5.7.23
```

* Then, create GLPI container with volume and link MySQL container

```sh
docker run --name glpi --link mysql:mysql --volume /var/www/html/glpi:/var/www/html/glpi -p 80:80 -d diouxx/glpi
```

Enjoy :)

## Deploy a specific release of GLPI
Default, docker run will use the latest release of GLPI.
For an usage on production environnement, it's recommanded to set specific release.
Here an example for release 9.1.6 :
```sh
docker run --name glpi --hostname glpi --link mysql:mysql --volume /var/www/html/glpi:/var/www/html/glpi -p 80:80 --env "VERSION_GLPI=9.1.6" -d diouxx/glpi
```

# Deploy with docker-compose

## Deploy without persistence data ( for quickly test )
```yaml
version: "3.2"

services:
#Mysql Container
  mysql:
    image: mysql:5.7.23
    container_name: mysql
    hostname: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=glpidb
      - MYSQL_USER=glpi_user
      - MYSQL_PASSWORD=glpi

#GLPI Container
  glpi:
    image: diouxx/glpi
    container_name : glpi
    hostname: glpi
    ports:
      - "80:80"
```

## Deploy with persistence data

To deploy with docker compose, you use *docker-compose.yml* and *mysql.env* file.
You can modify **_mysql.env_** to personalize settings like :

* MySQL root password
* GLPI database
* GLPI user database
* GLPI user password


### mysql.env
```
MYSQL_ROOT_PASSWORD=diouxx
MYSQL_DATABASE=glpidb
MYSQL_USER=glpi_user
MYSQL_PASSWORD=glpi
```

### docker-compose .yml
```yaml
version: "3.2"

services:
#Mysql Container
  mysql:
    image: mysql:5.7.23
    container_name: mysql
    hostname: mysql
    volumes:
      - /var/lib/mysql:/var/lib/mysql
    env_file:
      - ./mysql.env
    restart: always

#GLPI Container
  glpi:
    image: diouxx/glpi
    container_name : glpi
    hostname: glpi
    ports:
      - "80:80"
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - /var/www/html/glpi/:/var/www/html/glpi
    environment:
      - TIMEZONE=Europe/Brussels
    restart: always
```

To deploy, just run the following command on the same directory as files

```sh
mkdir -p /etc/glpi/conf /var/lib/glpi /var/log/glpi
chown 33.33 -R /etc/glpi /var/lib/glpi /var/log/glpi
chown 33.33 install/ ../local_define.php 
docker-compose up -d
docker-compose down
```

# Environnment variables

## TIMEZONE
If you need to set timezone for Apache and PHP

From commande line
```sh
docker run --name glpi --hostname glpi --link mysql:mysql --volumes-from glpi-data -p 80:80 --env "TIMEZONE=Europe/Brussels" -d diouxx/glpi
```

From docker-compose

Modify this settings
```yaml
environment:
     TIMEZONE=Europe/Brussels
```
