#!/bin/bash

service apache2 start
service cron start

# File Permissions
# Pimcore requires write access to the following directories: /website/var and /pimcore.
# chown -R www-data:www-data /applications/http/ehl5/pimcore
# chown -R www-data:www-data /applications/http/ehl5/website/var

chown -R www-data:www-data /applications/http/ehl5/app/config
chown -R www-data:www-data /applications/http/ehl5/bin
chown -R www-data:www-data /applications/http/ehl5/composer.json
chown -R www-data:www-data /applications/http/ehl5/pimcore
chown -R www-data:www-data /applications/http/ehl5/var
chown -R www-data:www-data /applications/http/ehl5/web/pimcore
chown -R www-data:www-data /applications/http/ehl5/web/var
chmod ug+x bin/*

exec /bin/bash