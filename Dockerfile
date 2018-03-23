FROM ubuntu:16.04

MAINTAINER M.Ali

ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get -y upgrade

# Install vim
RUN apt-get -y install vim
# Install nano
RUN apt-get -y install nano
# Install sudo
RUN apt-get -y install sudo
# Install cron
RUN apt-get -y install cron

# Install apache
RUN apt-get -y install apache2
RUN apt-get -y install apache2-bin
RUN apt-get -y install apache2-data
RUN apt-get -y install apache2-utils

# Install mysql-client
RUN apt-get -y install mysql-client

# INSTALLING PHP 7.1 ON UBUNTU
# PHP 7.1 is not readily available on Ubuntu systems by default.
# To install it you must add a third-party PPA repository.
RUN apt-get -y install software-properties-common
RUN apt-get -y install python-software-properties
ENV LC_ALL=C.UTF-8
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update

# Istall php
RUN apt-get -y install php-common
RUN apt-get -y install php7.1
RUN apt-get -y install php7.1-cli
RUN apt-get -y install php7.1-common
RUN apt-get -y install php7.1-json
RUN apt-get -y install php7.1-opcache
RUN apt-get -y install php7.1-readline
RUN apt-get -y install php7.1-curl
RUN apt-get -y install php7.1-gd
RUN apt-get -y install php7.1-mbstring
RUN apt-get -y install php7.1-mysql
RUN apt-get -y install php7.1-odbc
RUN apt-get -y install php7.1-xml
RUN apt-get -y install php7.1-zip
RUN apt-get -y install php7.1-bz2
RUN apt-get -y install php7.1-intl
RUN apt-get -y install libapache2-mod-php7.1
RUN apt-get -y install php-pear
RUN apt-get -y install php-apcu
RUN apt-get -y install php-redis

# php settings
COPY settings/php.ini /etc/php/7.1/apache2/php.ini

# Install MSSQL drivers (freetds dblib)
RUN apt-get install -y php7.1-sybase
# freetds
COPY settings/freetds.conf /etc/freetds/freetds.conf

# Install bash-completion
RUN apt-get -y install bash-completion
# COPY /etc/skel/.bashrc /.bashrc

# Install magick
RUN apt-get -y install imagemagick
RUN apt-get -y install php-imagick

# Install xz-utils
RUN apt-get install xz-utils

# Install ffmpeg
RUN apt-get -y install ffmpeg

# LibreOffice, pdftotext, Inkscape, ...
RUN apt-get install -y libreoffice python3-uno libreoffice-math xfonts-75dpi poppler-utils inkscape libxrender1 libfontconfig1 ghostscript

# Install wkhtmltopdf
RUN apt-get install -y wkhtmltopdf

# Install pngcrush
RUN apt-get install -y pngcrush

# Install jpegoptim
RUN apt-get install -y jpegoptim

# Install libimage-exiftool-perl
RUN apt-get install -y libimage-exiftool-perl

# Install composer
RUN apt-get -y install composer

# a2nmod
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod vhost_alias

# vhost settings
RUN ln -snf ../sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN ln -snf ../sites-available/default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf
COPY settings/010-dev.publicera.ehl.lu.se.conf /etc/apache2/sites-enabled/010-dev.publicera.ehl.lu.se.conf

# session
RUN mkdir /var/lib/php/session && chmod 777 /var/lib/php/session

# Add crontab file in the cron directory
ADD settings/crontab /var/spool/cron/crontabs/root

# Give execution rights on the cron job
RUN chmod 0600 /var/spool/cron/crontabs/root
RUN chown root:crontab /var/spool/cron/crontabs/root

# Timezone
ENV TZ=Europe/Stockholm
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# locale support by PHP
RUN apt-get -y install locales-all

# hostname/hosts
RUN echo "devehl.localdomain" > /etc/hostname
RUN echo "127.0.1.1 devehl.localdomain" >> /etc/hosts

# start.sh
COPY settings/start.sh /start.sh
RUN chmod a+x /start.sh
CMD /start.sh

ENV DEBIAN_FRONTEND teletype












