#!/bin/sh
set -e

if [ -n "$FTP_LOGIN" ] && [ -n "$FTP_PASS" ]; then
    echo "Создание конфигурации для пользователя: $FTP_LOGIN"

    # Переносим базу в /tmp, так как в /etc/pure-ftpd проверки прав вызывают ошибку 421
    (echo "$FTP_PASS"; echo "$FTP_PASS") | pure-pw useradd "$FTP_LOGIN" -u tanzuuser -g tanzuuser -d /data -f /tmp/pureftpd.passwd
    pure-pw mkdb /tmp/pureftpd.pdb -f /tmp/pureftpd.passwd
else
    echo "Ошибка: Переменные FTP_LOGIN и FTP_PASS не заданы!"
    exit 1
fi

echo "Запуск Pure-FTPd в режиме Tanzu Rootless..."
# Внимание на путь к pdb: /tmp/pureftpd.pdb
# Добавлен флаг -w (разрешить поддержку ссылок и rootless домашних папок)
exec pure-ftpd -S 2121 -l puredb:/tmp/pureftpd.pdb -p 30000:30005 -E -j -H -u 1 -x -A -w

