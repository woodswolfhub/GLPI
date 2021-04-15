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
# https://hub.docker.com/_/mariadb
docker pull mariadb:10.5.9-focal
docker image save -o mariadb.20210414.tar.gz mariadb:10.5.9-focal
curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o docker-compose
```

# Administration

## Creating database dumps
```sh
docker exec mariadb sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
```

## Restoring data from dump files
```sh
docker exec -i mariadb sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < /some/path/on/your/host/all-databases.sql
```

# To deploy, just run the following command on the same directory as files

```sh
yum install docker
useradd glpi -u 33 - g 33 -G docker
mkdir -p /etc/glpi/conf /var/lib/glpi /var/log/glpi
chown glpi:glpi -R /etc/glpi /var/lib/glpi /var/log/glpi
chown  glpi:glpi install/ ../local_define.php 
su - glpi
git clone https://github.com/woodswolfhub/GLPI.git
exit
# installation de docker-compose si n'existe pas
cp ~glpi/GLPI/docker-compose /usr/local/bin/.
chmod u+x /usr/local/bin/docker-compose
su - glpi
cd GLPI/ssl
# edit doit.sh and set attribute certificate
sh doit.sh
cd ../firstrun
docker-compose up -d
# init GLPI 
docker-compose down
cd ../service
cp glpi.service docker-cleanup.timer docker-cleanup.service /etc/systemd/system/.
systemctl enable glpi
#systemctl enable docker-cleanup
#systemctl enable docker-cleanup.timer
sudo systemctl daemon-reload
# Start GLPI
service start glpi
#service start docker-cleanup
#service start docker-cleanup.timer
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
