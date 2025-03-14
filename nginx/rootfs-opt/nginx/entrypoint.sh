#!/usr/bin/env bash

set -e
[ "${DEBUG:-false}" == 'true' ] && set -x

# Load libraries
. /opt/keeper/scripts/liblog.sh

# Environment configuration for nginx
# Paths
export NGINX_SBIN_DIR="/sbin"
#export NGINX_VOLUME_DIR="${BITNAMI_VOLUME_DIR}/nginx"
export NGINX_BASE_DIR="/etc/nginx"
export NGINX_CONF_DIR="${NGINX_BASE_DIR}"
export NGINX_DEFAULT_CONF_DIR="${NGINX_BASE_DIR}/conf.default"
export NGINX_HTDOCS_DIR="${NGINX_BASE_DIR}/html"
export NGINX_TMP_DIR="/tmp"
export NGINX_LOGS_DIR="/var/log/nginx"
export NGINX_SERVER_BLOCKS_DIR="${NGINX_CONF_DIR}/sites-enabled"
export NGINX_CONF_FILE="/etc/nginx/nginx.conf"
export NGINX_PID_FILE="${NGINX_TMP_DIR}/nginx.pid"
export NGINX_CERTS_DIR="${NGINX_BASE_DIR}/certs"
export NGINX_DEFAULT_SITE_FASTCGI_TEMPL="server-fastcgi.conf"
export NGINX_DEFAULT_SITE_PROXY_TEMPL="server-proxy.conf"

#Exit cleanly
trap "{ /usr/sbin/service nginx stop; }" EXIT


if [[ "$1" = "/opt/keeper/scripts/run.sh" ]]; then
  info "** Starting NGINX setup **"

  if [ -n "$SITES" ]; then

#    # lets read all backends, separated by ';'
#    IFS=\; read -a SITES_SEPARATED <<<"$SITES"
#
#    # for each backend (in form of server_name=endpoint:port) we create proper file
#    for NAME_EQ_ENDPOINT in "${SITES_SEPARATED[@]}"; do
#      RAW_SERVER_ENDPOINT=${NAME_EQ_ENDPOINT#*=}
#      export SERVER_NAME=${NAME_EQ_ENDPOINT%=*}
#      export SERVER_ENDPOINT=${RAW_SERVER_ENDPOINT#*//}  # it clears url scheme, like http:// or https://
#      envsubst '$SERVER_NAME $SERVER_ENDPOINT' \
#        < /opt/keeper/nginx/sites-enabled/server-proxy.conf \
#        > ${NGINX_SERVER_BLOCKS_DIR}/${SERVER_NAME}.conf
#    done
#    unset SERVER_NAME SERVER_ENDPOINT

    [ "${PROXY:-false}" == 'true' ] && SITE_TEMPL=${NGINX_DEFAULT_SITE_PROXY_TEMPL} || SITE_TEMPL=${NGINX_DEFAULT_SITE_FASTCGI_TEMPL}

    export SERVER_NAME=$SITES
    export SERVER_ENDPOINT=$ENDPOINT
    envsubst '$SERVER_NAME $SERVER_ENDPOINT' \
      < /opt/keeper/nginx/sites-enabled/${SITE_TEMPL} \
      > ${NGINX_SERVER_BLOCKS_DIR}/${SERVER_NAME}.conf
    unset SERVER_NAME SERVER_ENDPOINT
  fi

  info "** NGINX setup finished! **"
fi

#Generate self-signed TLS certificates without passphrase
if [ "$NGINX_SKIP_SAMPLE_CERTS" = false ] && [[ ! -f "$NGINX_CERTS_DIR/server.crt" ]]; then
    # Check certificates directory exists and is writable
    if [[ -d "$NGINX_CERTS_DIR" && -w "$NGINX_CERTS_DIR" ]]; then
        info "** Starting self-signed HTTPS certificates generation **"
        SSL_KEY_FILE="$NGINX_CERTS_DIR/server.key"
        SSL_CERT_FILE="$NGINX_CERTS_DIR/server.crt"
        SSL_CSR_FILE="$NGINX_CERTS_DIR/server.csr"
        SSL_SUBJ="/CN=${SITES}"
        SSL_EXT="subjectAltName=DNS:${SITES},DNS:www.${SITES},IP:127.0.0.1"
        rm -f "$SSL_KEY_FILE" "$SSL_CERT_FILE"
        openssl genrsa -out "$SSL_KEY_FILE" 4096
        # OpenSSL version 1.0.x does not use the same parameters as OpenSSL >= 1.1.x
        if [[ "$(openssl version | grep -oE "[0-9]+\.[0-9]+")" == "1.0" ]]; then
            openssl req -new -sha256 -out "$SSL_CSR_FILE" -key "$SSL_KEY_FILE" -nodes -subj "$SSL_SUBJ"
        else
            openssl req -new -sha256 -out "$SSL_CSR_FILE" -key "$SSL_KEY_FILE" -nodes -subj "$SSL_SUBJ" -addext "$SSL_EXT"
        fi
        openssl x509 -req -sha256 -in "$SSL_CSR_FILE" -signkey "$SSL_KEY_FILE" -out "$SSL_CERT_FILE" -days 1825 -extfile <(echo -n "$SSL_EXT")
        rm -f "$SSL_CSR_FILE"
        info "** Finish self-signed HTTPS certificates generation **"
    else
        warn "The certificates directories '$NGINX_CERTS_DIR' does not exist or is not writable, skipping self-signed HTTPS certificates generation"
    fi
fi

echo ""
exec "$@"