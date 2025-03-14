#!/bin/bash

set -e
[ "${DEBUG:-false}" == 'true' ] && set -x

# Load libraries
. /opt/keeper/scripts/liblog.sh

info "** Preparing MODX... **"
info "** Copying MODX... **"
mv $SRC_ROOT/* $HTML_ROOT

info "** Configuring MODX... **"
cp $HTML_ROOT/_build/build.config.sample.php $HTML_ROOT/_build/build.config.php
cp $HTML_ROOT/_build/build.properties.sample.php $HTML_ROOT/_build/build.properties.php


cat << EOF | tee $HTML_ROOT/_build/build.config.php
<?php
/* define the MODX path constants necessary for core installation */
define('MODX_CORE_PATH', dirname(__DIR__) . '/core/');
define('MODX_CONFIG_KEY', 'config');
/* define the connection variables */
define('XPDO_DSN', 'mysql:host=$MODX_DB_SERVER;dbname=$MYSQL_DATABASE;charset=$MODX_DB_CONNECTION_CHARSET');
define('XPDO_DB_USER', '$MYSQL_USER');
define('XPDO_DB_PASS', '$MYSQL_PASSWORD');
define('XPDO_TABLE_PREFIX', '$MODX_TABLE_PREFIX');
EOF

info "** Install PHP Composer **"
composer install --prefer-dist

info "** Building MODX... **"
php $HTML_ROOT/_build/transport.core.php
rm -r $HTML_ROOT/_build

if [[ $MODX_INSTALL_TYPE == "cli" ]]; then
    bash /opt/keeper/scripts/modx-cli-install.sh;
fi

info "** Fixing permissions.. **"
chmod -R 0755 $HTML_ROOT
chown daemon:root -R $HTML_ROOT

info "** MODX is ready **"