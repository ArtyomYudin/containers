FROM debian:11 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      wget \
      build-essential \
      autoconf \
      automake \
      libtool \
      bison \
      re2c \
      pkg-config \
      libxml2-dev \
      libjpeg-dev \
      libpng-dev \
      libfreetype6-dev \
      zlib1g-dev \
      libxslt1-dev  && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# OpenSSL 1.0.2u
RUN wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2u/openssl-1.0.2u.tar.gz && \
    tar xzf openssl-1.0.2u.tar.gz

WORKDIR /tmp/openssl-1.0.2u

RUN ./config \
      --prefix=/opt/openssl-1.0.2 \
      shared && \
    make -j$(nproc) && \
    make install

# curl

WORKDIR /tmp

RUN wget https://curl.se/download/curl-7.88.1.tar.gz && \
    tar xzf curl-7.88.1.tar.gz

WORKDIR /tmp/curl-7.88.1

RUN ./configure \
      --prefix=/opt/curl \
      --with-ssl=/opt/openssl-1.0.2 && \
    make -j$(nproc) && \
    make install

# PHP

WORKDIR /tmp

RUN wget https://www.php.net/distributions/php-5.3.29.tar.gz && \
    tar xzf php-5.3.29.tar.gz

WORKDIR /tmp/php-5.3.29

ENV PKG_CONFIG_PATH=/opt/openssl-1.0.2/lib/pkgconfig
ENV LD_LIBRARY_PATH=/opt/openssl-1.0.2/lib

RUN ./configure \
      --prefix=/opt/php5 \
      --sysconfdir=/opt/php5/etc \
      --enable-fpm \
      --enable-bcmath \
      --enable-calendar \
      --enable-mbstring \
      --enable-soap \
      --enable-sockets \
      --enable-zip \
      --enable-ftp \
      --enable-mysqlnd \
      --with-mysql=mysqlnd \
      --with-mysqli=mysqlnd \
      --with-pdo-mysql=mysqlnd \
      --with-openssl=/opt/openssl-1.0.2 \
      --with-curl=/opt/curl \
      --with-zlib \
      --with-gd \
      --with-jpeg-dir=/usr \
      --with-png-dir=/usr \
      --with-freetype-dir=/usr \
      --with-xsl \
      --with-libxml-dir=/usr && \
    make -j$(nproc) && \
    make install

RUN cp php.ini-production /opt/php5/etc/php.ini

RUN mkdir -p /runtime-libs && \
    ldd /opt/php5/sbin/php-fpm | awk '{print $3}' | grep '^/' | xargs -I{} cp -L {} /runtime-libs/ || true

#########################################################

FROM bitnami/minideb:bullseye

RUN install_packages \
      ca-certificates \
      libxml2 \
      libjpeg62-turbo \
      libpng16-16 \
      libxslt1.1 \
      zlib1g \
      libfreetype6

COPY --from=builder /opt/php5 /opt/php5
COPY --from=builder /opt/curl /opt/curl
COPY --from=builder /opt/openssl-1.0.2 /opt/openssl-1.0.2

# COPY --from=builder /runtime-libs /runtime-libs

ENV PATH="/opt/php5/bin:/opt/php5/sbin:/opt/curl/bin:${PATH}"
ENV LD_LIBRARY_PATH="/runtime-libs:/opt/openssl-1.0.2/lib"

RUN groupadd -g 1001 php && \
    useradd -u 1001 -g 1001 -d /app -s /usr/sbin/nologin php

RUN mkdir -p \
      /app \
      /opt/php5/tmp \
      /opt/php5/logs \
      /opt/php5/etc/pool.d && \
    chown -R 1001:1001 \
      /app \
      /opt/php5

COPY rootfs-opt/php-fpm/php-fpm.conf /opt/php5/etc/php-fpm.conf
COPY rootfs-opt/php-fpm/www.conf /opt/php5/etc/pool.d/www.conf

USER 1001:1001

WORKDIR /app

EXPOSE 9000

CMD ["/opt/php5/sbin/php-fpm","-F","-y","/opt/php5/etc/php-fpm.conf"]