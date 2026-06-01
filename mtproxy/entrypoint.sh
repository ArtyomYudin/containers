#!/usr/bin/env bash
set -e

PORT="${PORT:-443}"
WORKERS="${WORKERS:-1}"
TLS_DOMAIN="${TLS_DOMAIN:-www.cloudflare.com}"

CONF_DIR="/etc/mtproxy"

mkdir -p ${CONF_DIR}

echo "[1/6] Download configs"
curl -fsSL https://core.telegram.org/getProxySecret -o ${CONF_DIR}/proxy-secret
curl -fsSL https://core.telegram.org/getProxyConfig -o ${CONF_DIR}/proxy-multi.conf

if [ ! -s "${CONF_DIR}/proxy-secret" ] || [ ! -s "${CONF_DIR}/proxy-multi.conf" ]; then
    echo "ERROR: Downloaded configs are empty or missing!"
    exit 1
fi

echo "[2/6] Generate secret"
if [ ! -f ${CONF_DIR}/user-secret ]; then
    openssl rand -hex 16 > ${CONF_DIR}/user-secret
fi

SECRET=$(cat ${CONF_DIR}/user-secret)

echo "[3/6] Generate FakeTLS secret"
TLS_SECRET="ee${SECRET}$(echo -n ${TLS_DOMAIN} | xxd -ps -c 256)"

echo "[4/6] Detect IP"
PUBLIC_IP=$(curl -4fsSL https://api.ipify.org || true)

echo
echo "========= MTProxy FakeTLS ========="
echo "Domain: ${TLS_DOMAIN}"
echo "Secret: ${SECRET}"
echo
echo "tg://proxy?server=${PUBLIC_IP}&port=${PORT}&secret=${TLS_SECRET}"
echo
echo "https://t.me/proxy?server=${PUBLIC_IP}&port=${PORT}&secret=${TLS_SECRET}"
echo "==================================="
echo

echo "[5/6] start updater background"
/updater.sh &

echo "[6/6] Start MTProxy"

exec /usr/local/bin/mtproto-proxy \
  -u nobody \
  -p 8888 \
  -H ${PORT} \
  -S ${SECRET} \
  --aes-pwd ${CONF_DIR}/proxy-secret ${CONF_DIR}/proxy-multi.conf \
  -M ${WORKERS} \
  -D ${TLS_DOMAIN}