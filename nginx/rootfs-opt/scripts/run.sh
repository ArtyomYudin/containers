#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

export NGINX_SBIN_DIR="/sbin"
#export NGINX_SBIN_DIR="/opt/bitnami/nginx/sbin"
export NGINX_CONF_FILE="/etc/nginx/nginx.conf"

# Load libraries
. /opt/keeper/scripts/liblog.sh


info "** Starting NGINX **"
exec "${NGINX_SBIN_DIR}/nginx" -c "$NGINX_CONF_FILE" -g "daemon off;"
