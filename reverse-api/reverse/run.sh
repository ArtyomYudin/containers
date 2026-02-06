#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

#export NGINX_SBIN_DIR="/sbin"
##export NGINX_SBIN_DIR="/opt/bitnami/nginx/sbin"
#export NGINX_CONF_FILE="/etc/nginx/nginx.conf"
#
## Load libraries
#. /opt/keeper/scripts/liblog.sh


#info "** Starting Reverse API **"
echo "** Starting Reverse API **"
exec /opt/reverse-api/ReverseApiServer -e
