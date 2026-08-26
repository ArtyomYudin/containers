FROM alpine:latest

# Устанавливаем только базовый vsftpd, pam и bash
RUN apk add --no-cache vsftpd linux-pam bash

# Создаем rootless пользователя (UID 1001)
RUN addgroup -g 1001 tanzuuser && \
    adduser -u 1001 -G tanzuuser -h /home/tanzuuser -D tanzuuser

# Создаем необходимые директории и выставляем права
RUN mkdir -p /etc/vsftpd /var/run/vsftpd /data /var/log/vsftpd && \
    chown -R tanzuuser:tanzuuser /etc/vsftpd /var/run/vsftpd /data /var/log/vsftpd

# Копируем конфигурационные файлы
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY vsftpd.virtual /etc/pam.d/vsftpd.virtual
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && chown tanzuuser:tanzuuser /entrypoint.sh

# Даем права на PAM директорию, чтобы не-root пользователь мог читать правила авторизации
RUN chown -R tanzuuser:tanzuuser /etc/pam.d/

# Переключаемся на безопасного пользователя
USER 1001
ENTRYPOINT ["/entrypoint.sh"]
