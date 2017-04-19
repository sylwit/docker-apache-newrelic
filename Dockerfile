FROM php:7.0-apache

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
        zip \
        unzip \
    && docker-php-ext-install -j$(nproc) mcrypt mbstring pdo pdo_mysql mysqli \
    && a2enmod rewrite \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Configure locales
RUN echo 'fr_CA.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen

ENV LANG fr_CA.UTF-8
ENV LANGUAGE fr_CA:en
ENV LC_ALL fr_CA.UTF-8

RUN echo "America/New_York" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata


RUN pecl install imagick-3.4.1 redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable imagick redis

ENV NR_INSTALL_SILENT 1
RUN newrelic-install install \
    && sed -i \
        -e "s/newrelic.license =.*/newrelic.license = \${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NEW_RELIC_APP_NAME}/" \
        /usr/local/etc/php/conf.d/newrelic.ini


RUN rm -Rf /var/www/html

WORKDIR /var/www
