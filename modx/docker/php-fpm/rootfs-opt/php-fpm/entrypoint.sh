#!/usr/bin/env bash
set -e
[ "${DEBUG:-false}" == 'true' ] && set -x

# Load libraries
. /opt/keeper/scripts/liblog.sh

info "** MODX Runtime Initialization **"

# Проверка наличия основных файлов
if [ ! -f "${HTML_ROOT}/index.php" ]; then
    error "MODX core files not found! Check your volume mounts."
    exit 1
fi

# Генерация config.inc.php если не существует
if [ ! -f "${HTML_ROOT}/core/config/config.inc.php" ]; then
    info "** Generating MODX config.inc.php **"

    # Валидация обязательных переменных
    if [ -z "$MODX_DB_SERVER" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ]; then
        error "Database configuration is missing!"
        error "Required env vars: MODX_DB_SERVER, MYSQL_DATABASE, MYSQL_USER"
        exit 1
    fi

    cat << EOF > "${HTML_ROOT}/core/config/config.inc.php"
<?php
/**
 * MODX Runtime Configuration
 * Generated at: $(date -Iseconds)
 */

\$database_type     = 'mysql';
\$database_server   = '${MODX_DB_SERVER}';
\$database          = '${MYSQL_DATABASE}';
\$database_user     = '${MYSQL_USER}';
\$database_password = '${MYSQL_PASSWORD}';
\$table_prefix      = '${MODX_TABLE_PREFIX:-modx_}';
\$charset           = '${MODX_DB_CONNECTION_CHARSET:-utf8mb4}';

\$http_host         = '${MODX_HTTP_HOST:-localhost}';
\$https_port        = '${MODX_HTTPS_PORT:-443}';

// Include default configuration
if (file_exists(MODX_CORE_PATH . 'config/' . MODX_CONFIG_KEY . '.inc.php')) {
    include MODX_CORE_PATH . 'config/' . MODX_CONFIG_KEY . '.inc.php';
}
EOF

    chmod 440 "${HTML_ROOT}/core/config/config.inc.php"
    chown 1001:1001 "${HTML_ROOT}/core/config/config.inc.php"
    info "✓ Config generated successfully"
else
    info "✓ Config already exists, skipping generation"
fi

# Проверка подключения к БД (опционально)
if [ "${MODX_CHECK_DB:-false}" == "true" ]; then
    info "** Checking database connection **"
    if command -v mysql &> /dev/null; then
        if ! mysql -h "${MODX_DB_SERVER}" -u "${MYSQL_USER}" \
                -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1" &>/dev/null; then
            error "Cannot connect to database!"
            exit 1
        fi
        info "✓ Database connection successful"
    fi
fi

info "** MODX is ready to serve **"
exec "$@"