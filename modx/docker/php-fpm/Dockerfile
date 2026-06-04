# =============================================================================
# Stage 1: Builder - Установка зависимостей и сборка MODX
# =============================================================================
FROM hanna.center-inform.ru/bitnamilegacy/php-fpm:8.4.11 AS builder

LABEL authors="Artyom Yudin"
LABEL stage="builder"

ENV MODX_VER=3.1.2 \
    TEMP_DIR=/tmp \
    SRC_ROOT=/tmp/modx \
    HTML_ROOT=/app \
    COMPOSER_ALLOW_SUPERUSER=1

## Установка системных зависимостей (включая unzip)
#RUN if ! command -v unzip &> /dev/null; then \
#        apt-get update && \
#        apt-get install -y --no-install-recommends unzip curl git && \
#        rm -rf /var/lib/apt/lists/*; \
#    fi

# Подготовка директорий
RUN mkdir -p /opt/keeper ${SRC_ROOT} ${HTML_ROOT} && \
    chmod -R 755 /opt/keeper

# Копирование кастомных скриптов
COPY rootfs-opt /opt/keeper/

# Скачивание и распаковка MODX
RUN curl -fsSL -o ${TEMP_DIR}/modx.tar.gz \
        https://github.com/modxcms/revolution/archive/v${MODX_VER}-pl.tar.gz && \
    tar xfvz ${TEMP_DIR}/modx.tar.gz -C ${TEMP_DIR}/modx --strip=1 \
        revolution-${MODX_VER}-pl/connectors \
        revolution-${MODX_VER}-pl/core \
        revolution-${MODX_VER}-pl/manager \
        revolution-${MODX_VER}-pl/setup \
        revolution-${MODX_VER}-pl/_build \
        revolution-${MODX_VER}-pl/index.php \
        revolution-${MODX_VER}-pl/ht.access \
        revolution-${MODX_VER}-pl/composer.json && \
    mv ${TEMP_DIR}/modx/* ${HTML_ROOT}/

# Установка Composer зависимостей
WORKDIR ${HTML_ROOT}
RUN composer install --prefer-dist --no-dev --no-interaction --no-progress \
        --optimize-autoloader --classmap-authoritative

# Сборка транспорта MODX
#RUN cp ${HTML_ROOT}/_build/build.config.sample.php ${HTML_ROOT}/_build/build.config.php && \
#    php ${HTML_ROOT}/_build/transport.core.php && \
#    rm -rf ${HTML_ROOT}/_build ${TEMP_DIR}/*
RUN cp ${HTML_ROOT}/_build/build.config.sample.php ${HTML_ROOT}/_build/build.config.php && \
    cp $HTML_ROOT/_build/build.properties.sample.php $HTML_ROOT/_build/build.properties.php && \
    php ${HTML_ROOT}/_build/transport.core.php
RUN rm -rf ${TEMP_DIR}/*


RUN cat > ${HTML_ROOT}/config.core.php <<'EOF'
<?php

if (!defined('MODX_CORE_PATH')) {
    define('MODX_CORE_PATH', '/app/core/');
}

if (!defined('MODX_CONFIG_KEY')) {
    define('MODX_CONFIG_KEY', 'config');
}
EOF
RUN cp ${HTML_ROOT}/config.core.php ${HTML_ROOT}/manager/config.core.php && \
    cp ${HTML_ROOT}/config.core.php ${HTML_ROOT}/connectors/config.core.php


# Фиксация прав
#RUN chmod -R 0755 ${HTML_ROOT} && \
#    chown -R daemon:root ${HTML_ROOT}
RUN chown -R 1001:1001 ${HTML_ROOT}

# =============================================================================
# Stage 2: Runtime - Минимальный образ для запуска
# =============================================================================
FROM hanna.center-inform.ru/bitnamilegacy/php-fpm:8.4.11 AS runtime

LABEL authors="Artyom Yudin"
LABEL stage="runtime"
LABEL description="MODX Revolution 3.1.2 - Production Ready"

ENV HTML_ROOT=/app \
    MODX_DB_SERVER= \
    MYSQL_DATABASE= \
    MYSQL_USER= \
    MYSQL_PASSWORD= \
    MODX_TABLE_PREFIX=modx_ \
    MODX_DB_CONNECTION_CHARSET=utf8mb4 \
    MODX_HTTP_HOST=localhost \
    MODX_HTTPS_PORT=443

# Копирование готового приложения из builder
COPY --from=builder --chown=1001:1001 ${HTML_ROOT} ${HTML_ROOT}

RUN chmod -R 775 ${HTML_ROOT}

# Копирование скриптов из builder (также с правильными правами)
COPY --from=builder /opt/keeper /opt/keeper/

# Создание директорий для сессий и кэша с правильными правами
RUN mkdir -p ${HTML_ROOT}/core/cache ${HTML_ROOT}/core/components \
        ${HTML_ROOT}/core/packages ${HTML_ROOT}/assets/components && \
    chmod -R 0775 ${HTML_ROOT}/core/cache ${HTML_ROOT}/core/components \
        ${HTML_ROOT}/assets/components ${HTML_ROOT}/core/packages && \
    chown -R 1001:1001 ${HTML_ROOT}/core/cache ${HTML_ROOT}/core/components \
        ${HTML_ROOT}/assets/components ${HTML_ROOT}/core/packages

## Перед ENTRYPOINT создание пустого файла config.inc.php с правами на запись для UID 1001
#RUN mkdir -p ${HTML_ROOT}/core/config && \
#    touch ${HTML_ROOT}/core/config/config.inc.php && \
#    chmod 666 ${HTML_ROOT}/core/config/config.inc.php && \
#    chown -R 1001:1001 ${HTML_ROOT}/core/config
# Создаем директорию для конфига и отдаем полные права пользователю 1001
RUN mkdir -p ${HTML_ROOT}/core/config && \
    chmod -R 0775 ${HTML_ROOT}/core/config && \
    chown -R 1001:1001 ${HTML_ROOT}/core/config

# Создание директории для PID-файла и выдача прав пользователю 1001
RUN mkdir -p /opt/bitnami/php/tmp && \
    chown -R 1001:1001 /opt/bitnami/php/tmp && \
    chmod 0775 /opt/bitnami/php/tmp

# Создаем директорию для логов и даем полные права пользователю 1001
RUN mkdir -p /opt/bitnami/php/logs && \
    chown -R 1001:1001 /opt/bitnami/php/logs

## Перенаправляем лог php-fpm в стандартный поток ошибок контейнера (опционально, но рекомендуется)
#RUN ln -sf /dev/stderr /opt/bitnami/php/logs/php-fpm.log

# Health check для Kubernetes
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php -r "exit(file_exists('${HTML_ROOT}/index.php') ? 0 : 1);" || exit 1

EXPOSE 9000/TCP

# Entry point для runtime-конфигурации
ENTRYPOINT ["/opt/keeper/php-fpm/entrypoint.sh"]
CMD ["php-fpm", "-F", "--pid", "/opt/bitnami/php/tmp/php-fpm.pid", "-y", "/opt/bitnami/php/etc/php-fpm.conf"]

USER 1001