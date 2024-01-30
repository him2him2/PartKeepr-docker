FROM php:7.1-apache-buster

RUN apt-get update 
RUN apt-get upgrade -y 

RUN apt-get install -y sudo curl wget git unzip libldap2-dev libpng++-dev libicu-dev libcurl4-gnutls-dev libxml2-dev libpq-dev libfreetype6-dev nano less vim
RUN apt-get clean 
RUN docker-php-ext-configure ldap 
RUN docker-php-ext-install ldap 
RUN docker-php-ext-configure bcmath && docker-php-ext-install bcmath 
 
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype2 
RUN docker-php-ext-install gd
RUN docker-php-ext-install opcache intl dom pdo pdo_mysql pdo_pgsql 

RUN git clone https://github.com/partkeepr/PartKeepr.git

RUN cp app/config/parameters.php.dist  app/config/parameters.php

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"

RUN mv composer.phar /usr/local/bin/composer

RUN composer install
