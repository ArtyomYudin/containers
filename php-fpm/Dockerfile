FROM bitnami/minideb:bookworm

LABEL authors="Artyom Yudin" \
      org.opencontainers.image.base.name="" \
      org.opencontainers.image.created="" \
      org.opencontainers.image.description="Legacy PHP-FPM Application packaged by Keeper" \
      org.opencontainers.image.documentation="https://github.com/ArtyomYudin/containers/php-fpm/README.md" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="5.3.29-debian-12-r0" \
      org.opencontainers.image.source="https://github.com/ArtyomYudin/containers/php-fpm" \
      org.opencontainers.image.title="php-fpm" \
      org.opencontainers.image.vendor="" \
      org.opencontainers.image.version="5.3.29"


SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

# Install packages
RUN install_packages vim wget ca-certificates build-essential libxml2-dev libjpeg-dev libpng-dev \
    libfreetype6-dev libmcrypt-dev libxslt1-dev libkrb5-dev libltdl-dev \
    default-libmysqlclient-dev

# Download OpenSSL Source Code
WORKDIR "/tmp"
RUN wget -O openssl-1.0.2u.tar.gz https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz
RUN tar xzf openssl-1.0.2u.tar.gz
WORKDIR "/tmp/openssl-1.0.2u"
# Build and Install OpenSSL
RUN ./config shared --openssldir=/opt/openssl-1.0.2/ enable-ec_nistp_64_gcc_128
RUN make depend
RUN make
RUN make install
RUN ln -s /opt/openssl-1.0.2/lib /opt/openssl-1.0.2/lib/x86_64-linux-gnu
# Add OpenSSL libraries path to system runtime
RUN echo "/opt/openssl-1.0.2/lib" > /etc/ld.so.conf.d/openssl.conf \
# Update shared library cache
RUN ldconfig


# Download and unpack the source code for old curl
WORKDIR "/tmp"
RUN wget -O curl-7.88.1.tar.gz https://curl.se/download/curl-7.88.1.tar.gz
RUN tar xzf curl-7.88.1.tar.gz
WORKDIR "/tmp/curl-7.88.1"
# Configure Curl
RUN ./configure --prefix=/opt/curl --with-ssl=/opt/openssl-1.0.2 --with-ca-path=/etc/ssl/certs
# Compile and install Curl
RUN make
RUN make install


# Download the PHP Source Code
WORKDIR "/tmp"
RUN wget -O php-5.3.29.tar.gz https://www.php.net/distributions/php-5.3.29.tar.gz
RUN tar xzf php-5.3.29.tar.gz
WORKDIR "/tmp/php-5.3.29"
# Configure PHP 5.3
RUN ./configure --prefix=/opt/php5 --with-config-file-path=/opt/php5/etc --enable-fpm --with-fpm-user=www-data \
    --with-fpm-group=www-data --enable-bcmath --enable-opcache --enable-ftp --enable-gd-native-ttf --enable-libxml \
    --enable-mbstring --enable-soap --enable-sockets --enable-zip --with-curl=/opt/curl --with-freetype-dir=/usr \
    --with-gd --with-gettext --with-mcrypt --enable-mysqlnd --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-mysqli=mysqlnd --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-openssl=/opt/openssl-1.0.2 \
    --with-openssl-dir=/opt/openssl-1.0.2 --with-zlib --with-xsl --with-zlib-dir=/usr --enable-calendar \
    --enable-gd-native-ttf --with-jpeg-dir=/usr --with-png-dir=/usr
    #--with-imap=/opt/imap-2007f --with-imap-ssl
RUN make
RUN make install

RUN cp php.ini-production /opt/php5/etc/php.ini

RUN mkdir /opt/php5/etc/pool.d
RUN mkdir /opt/php5/tmp
RUN mkdir /opt/php5/logs


COPY rootfs-opt/php-fpm/php-fpm.conf /opt/php5/etc/
COPY rootfs-opt/php-fpm/www.conf /opt/php5/etc/pool.d/


RUN sed -i "s/short_open_tag = .*/short_open_tag = On/" /opt/php5/etc/php.ini
#RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize= 80M/" /opt/bitnami/php/etc/php.ini
#RUN sed -i "s/post_max_size = .*/post_max_size= 80M/" /opt/bitnami/php/etc/php.ini
RUN sed -i "s/mbstring.func_overload = .*/mbstring.func_overload= 2/" /opt/php5/etc/php.ini
RUN sed -i "s/mbstring.internal_encoding = .*/mbstring.internal_encoding= UTF-8/" /opt/php5/etc/php.ini


ENV PATH="/opt/php5/bin:/opt/php5/sbin:$PATH"
EXPOSE 9000
WORKDIR /app


CMD [ "php-fpm", "-F", "--pid", "/opt/php5/tmp/php-fpm.pid", "-y", "/opt/php5/etc/php-fpm.conf" ]


