FROM alpine:latest

# Устанавливаем pure-ftpd, shadow (для управления шеллами) и bash
RUN apk add --no-cache pure-ftpd shadow bash

# Создаем rootless пользователя (UID 1001) с валидным шеллом /bin/bash
RUN addgroup -g 1001 tanzuuser && \
    adduser -u 1001 -G tanzuuser -h /home/tanzuuser -s /bin/bash -D tanzuuser

# Создаем директории и выставляем права
RUN mkdir -p /etc/pure-ftpd /data && \
    chown -R tanzuuser:tanzuuser /etc/pure-ftpd /data

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown tanzuuser:tanzuuser /entrypoint.sh

USER 1001
ENTRYPOINT ["/entrypoint.sh"]
