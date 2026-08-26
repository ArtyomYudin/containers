#!/bin/sh
set -e

if [ -n "$FTP_LOGIN" ] && [ -n "$FTP_PASS" ]; then
    echo "Создание конфигурации для пользователя: $FTP_LOGIN"

    # Записываем пару логин:пароль для pam_plain
    echo "${FTP_LOGIN}:${FTP_PASS}" > /etc/vsftpd/vsftpd_users.conf
    chmod 600 /etc/vsftpd/vsftpd_users.conf
else
    echo "Ошибка: Переменные FTP_LOGIN и FTP_PASS не заданы!"
    exit 1
fi

echo "Запуск VSFTPD в режиме rootless..."
exec vsftpd /etc/vsftpd/vsftpd.conf
