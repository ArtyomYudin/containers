#!/usr/bin/env bash
set -e

CONF_DIR="/etc/mtproxy"

while true; do
    echo "[updater] refreshing telegram config..."

    # Скачиваем во временный файл, игнорируя ошибки (-f убираем или обрабатываем выход)
    if curl -fsSL https://core.telegram.org/getProxyConfig -o ${CONF_DIR}/proxy-multi.conf.tmp; then
        mv ${CONF_DIR}/proxy-multi.conf.tmp ${CONF_DIR}/proxy-multi.conf
    else
        echo "[updater] WARNING: Failed to download config, keeping old one"
        rm -f ${CONF_DIR}/proxy-multi.conf.tmp
    fi

    if curl -fsSL https://core.telegram.org/getProxySecret -o ${CONF_DIR}/proxy-secret.tmp; then
        mv ${CONF_DIR}/proxy-secret.tmp ${CONF_DIR}/proxy-secret
    else
        echo "[updater] WARNING: Failed to download secret, keeping old one"
        rm -f ${CONF_DIR}/proxy-secret.tmp
    fi

    echo "[updater] done"
    sleep 86400
done