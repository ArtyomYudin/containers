FROM alpine:latest

# Установка rsyslog с поддержкой PostgreSQL
RUN apk add --no-cache rsyslog rsyslog-pgsql postgresql-client

# Создание пользователя с фиксированными UID/GID
RUN addgroup -g 1001 -S rsyslog && \
    adduser -u 1001 -S rsyslog -G rsyslog -h /home/rsyslog -s /bin/sh

# Создание директории для конфигов
RUN mkdir -p /etc/rsyslog && \
    chown -R rsyslog:rsyslog /etc/rsyslog /home/rsyslog

# Для SSL сертификатов PostgreSQL
ENV HOME=/home/rsyslog

USER 1001

CMD ["rsyslogd", "-n", "-f", "/etc/rsyslog/rsyslog.conf"]