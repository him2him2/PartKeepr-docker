FROM php:7.1-apache-buster

RUN apt-get update 
RUN apt-get upgrade -y 
RUN apt-get install -y sudo  curl wget git unzip libldap2-dev libpng++-dev libicu-dev libcurl4-gnutls-dev libxml2-dev libpq-dev libfreetype6-dev nano less vim php-pear
#RUN apt-get install -y php-pear
RUN apt-get clean
RUN docker-php-ext-configure ldap 
RUN docker-php-ext-install ldap 
RUN docker-php-ext-configure bcmath 
RUN docker-php-ext-install bcmath 
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype2 
RUN docker-php-ext-install gd 
RUN docker-php-ext-install opcache intl dom pdo pdo_mysql pdo_pgsql 
#RUN pecl install xdebug 
#RUN docker-php-ext-enable xdebug
#RUN pecl install apcu_bc-beta 
RUN docker-php-ext-enable apcu apc 
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini 
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-apc.ini /usr/local/etc/php/conf.d/20-docker-php-ext-apc.ini

RUN mkdir /var/www/pk && chown www-data /var/www/pk

WORKDIR /var/www/pk

# Setup Apache settings
RUN a2enmod rewrite
RUN find /etc/apache2 -type f -exec sed 's@/var/www/html@/var/www/pk/web@g' -i \{\} +

# Install Composer
# See https://tecnstuff.net/how-to-install-composer-on-debian-10/
RUN cd /tmp && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	HASH="$(wget -q -O - https://composer.github.io/installer.sig)" && \
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); } echo PHP_EOL;" && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version 1.10.9

COPY xdebug.config /tmp
RUN cat /tmp/xdebug.config >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	rm /tmp/xdebug.config
