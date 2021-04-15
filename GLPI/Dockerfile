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
COPY --chown=root:root glpi-install.sh /usr/local/bin/
# Installation de GLPI
RUN chmod +x /usr/local/bin/glpi-install.sh && /bin/bash /usr/local/bin/glpi-install.sh
# Installation de la configuration des données de GLPI
COPY --chown=www-data:www-data downstream.php /var/www/html/glpi/inc/ 
# Installation du fichier de répertoires par defaut
COPY --chown=www-data:www-data local_define.php /etc/glpi/ 

# Creation des répertoires de GLPI
RUN mkdir -p /etc/glpi/conf /var/lib/glpi /var/log/glpi && chown www-data:www-data /etc/glpi/conf /var/lib/glpi /var/log/glpi

RUN echo "ServerName \${APACHE_SERVERNAME}" >> /etc/apache2/apache2.conf
ENV APACHE_SERVERNAME="example.com"
# max memory limit
ENV PHP_MEMORY_LIMIT="64M"
ENV PHP_FILE_UPLOADS="On"
#not mandatory but recommended
ENV PHP_MAX_EXECUTION_TIME="600"
ENV PHP_SESSION.AUTO_START="off"
#not mandatory but recommended
ENV PHP_SESSION.USE_TRANS_SID="0" 

# Create a self signed certificate
RUN openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes  -keyout /etc/glpi/ssl-cert.key -days 10000 -out /etc/glpi/ssl-cert.pem \
	-subj "/CN=example.com" -addext "subjectAltName=DNS:example.com,DNS:www.example.net,IP:10.0.0.1" && \
	chown www-data:www-data /etc/glpi/ssl-cert.key /etc/glpi/ssl-cert.pem

COPY --chown=root:root site-glpi.conf /etc/apache2/sites-available/.
COPY --chown=root:root site-glpi-ssl.conf /etc/apache2/sites-available/.
RUN rm -f /etc/apache2/sites-enabled/000-default.conf && cd /etc/apache2/sites-enabled && \
	ln -s ../sites-available/site-glpi.conf . && ln -s ../sites-available/site-glpi-ssl.conf . && \
	rm -f /var/www/html/index.html

COPY --chown=root:root  ./glpi-start.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/glpi-start.sh"] 
