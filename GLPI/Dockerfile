#On choisit une debian
FROM debian:stable-slim

MAINTAINER Carl "carl.castanier@external.thalesgroup.com"
# Original MAINTAINER DiouxX "github@diouxx.be"

#Ne pas poser de question à l'installation
ENV DEBIAN_FRONTEND noninteractive

#Installation d'apache et de php7.3 avec extension
RUN apt update \
&& apt install --yes --no-install-recommends \
apache2 \
php7.3 \
php7.3-mysql \
php7.3-ldap \
php7.3-xmlrpc \
php7.3-imap \
curl \
php7.3-curl \
php7.3-gd \
php7.3-mbstring \
php7.3-xml \
php7.3-apcu-bc \
php-cas \
php7.3-intl \
php7.3-zip \
php7.3-bz2 \
cron \
wget \
ca-certificates \
jq \
&& rm -rf /var/lib/apt/lists/*

#Exposition des ports
EXPOSE 80 443

#Copie et execution du script pour l'installation et l'initialisation de GLPI
COPY glpi-install.sh /usr/local/bin/
# Installation de GLPI
RUN chmod +x /usr/local/bin/glpi-install.sh && /bin/bash /usr/local/bin/glpi-install.sh
# Installation de la configuration des données de GLPI
COPY downstream.php /var/www/html/glpi/inc/ 
# Installation du fichier de répertoires par defaut
COPY local_define.php /etc/glpi/ 

# Creation des répertoires de GLPI
RUN mkdir -p /etc/glpi/conf /var/lib/glpi /var/log/glpi && chown 33:33 /etc/glpi/conf /var/lib/glpi /var/log/glpi /var/www/html/glpi/inc/downstream.php /etc/glpi/local_define.php 

# openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes  -keyout ssl-cert.key -days 10000 -out ssl-cert.pem -subj "/CN=example.com" -addext "subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1"

COPY ./glpi-start.sh /usr/local/bin/
CMD ["/usr/local/bin/glpi-start.sh"] 
