FROM php:7.1-apache

ENV TERM xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

RUN curl https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list

#RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        locales \
        libmcrypt-dev \
        imagemagick \
        ghostscript \
        libmagickwand-dev \
        newrelic-php5 \
    && docker-php-ext-install -j$(nproc) mcrypt mbstring pdo pdo_mysql mysqli \
    && a2enmod rewrite \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "America/New_York" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

RUN pecl install imagick redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable imagick redis

ARG NR_INSTALL_SILENT=1
RUN newrelic-install install \
    && sed -i \
        -e "s/newrelic.license =.*/newrelic.license = \${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NEW_RELIC_APP_NAME}/" \
        /usr/local/etc/php/conf.d/newrelic.ini

RUN rm -Rf /var/www/html

WORKDIR /var/www
