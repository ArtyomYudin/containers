FROM bitnami/php-fpm:8.4.4-debian-12-r5

LABEL authors="Artyom Yudin"

ENV MODX_VER=3.1.1
ENV TEMP_DIR=/tmp
ENV SRC_ROOT=/tmp/modx
ENV HTML_ROOT=/app


RUN mkdir /opt/keeper
RUN chmod g+rwX /opt/keeper

RUN mkdir /tmp/modx

COPY rootfs-opt /opt/keeper/

RUN curl -o ${TEMP_DIR}/modx.tar.gz -SL https://github.com/modxcms/revolution/archive/v${MODX_VER}-pl.tar.gz
RUN tar xfvz ${TEMP_DIR}/modx.tar.gz -C ${TEMP_DIR}/modx --strip=1 \
        revolution-$MODX_VER-pl/connectors \
        revolution-$MODX_VER-pl/core \
        revolution-$MODX_VER-pl/manager \
        revolution-$MODX_VER-pl/setup \
        revolution-$MODX_VER-pl/_build \
        revolution-$MODX_VER-pl/index.php \
        revolution-$MODX_VER-pl/ht.access \
        revolution-$MODX_VER-pl/composer.json

EXPOSE 9000/TCP

ENTRYPOINT [ "/opt/keeper/php-fpm/entrypoint.sh" ]
CMD [ "php-fpm", "-F", "--pid", "/opt/bitnami/php/tmp/php-fpm.pid", "-y", "/opt/bitnami/php/etc/php-fpm.conf" ]