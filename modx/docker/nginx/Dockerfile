FROM hanna.center-inform.ru/bitnamilegacy/nginx:1.29.1

LABEL authors="Artyom Yudin"
LABEL description="NGINX for MODX Revolution 3.2.1-r3"

USER root

COPY --from=hanna.center-inform.ru/modx/modx:3.2.1-r3 /app/index.php /app/index.php
COPY --from=hanna.center-inform.ru/modx/modx:3.2.1-r3 /app/manager /app/manager
COPY --from=hanna.center-inform.ru/modx/modx:3.2.1-r3 /app/connectors /app/connectors
COPY --from=hanna.center-inform.ru/modx/modx:3.2.1-r3 /app/core /app/core

RUN rm -rf \
    /app/core/cache \
    /app/core/config \
    /app/core/packages

RUN mkdir -p \
    /app/core/cache \
    /app/core/config \
    /app/core/packages \
    /app/assets

RUN chown -R 1001:1001 /app

USER 1001


