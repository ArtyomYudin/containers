# Debian Bookworm
FROM bitnami/minideb:bookworm

LABEL authors="Artyom Yudin" \
      org.opencontainers.image.base.name="docker.io/artyomyudin/nginx:1.22.1" \
      org.opencontainers.image.created="" \
      org.opencontainers.image.description="NGINX Application packaged by Keeper" \
      org.opencontainers.image.documentation="https://github.com/ArtyomYudin/containers/tree/main/nginx/README.md" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="1.21.1-debian-12-r0" \
      org.opencontainers.image.source="https://github.com/ArtyomYudin/containers/tree/main/nginx" \
      org.opencontainers.image.title="nginx" \
      org.opencontainers.image.vendor="" \
      org.opencontainers.image.version="1.21.1"

ENV SITES="test.ru" \
    ENDPOINT="php-fpm" \
    TZ="" \
    NGINX_SKIP_SAMPLE_CERTS="false" \
    PROXY="false"

ARG UID=101
ARG GID=101

SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

#create nginx user/group first, to be consistent throughout docker variants
RUN groupadd --system --gid $GID nginx || true
RUN useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid $UID nginx || true

# Install packages
RUN install_packages nginx openssl curl procps gettext
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives


RUN mkdir /opt/keeper
RUN mkdir /etc/nginx/certs
RUN chmod g+rwX /opt/keeper
#RUN mkdir /app
#RUN chmod g+rwX /app

COPY rootfs-opt /opt/keeper/

# implement changes required to run NGINX as an unprivileged user
RUN  \
     #sed -i 's,listen       80;,listen       8080;,' /etc/nginx/conf.d/default.conf \
    sed -i '/user www-data;/d' /etc/nginx/nginx.conf \
    && sed -i 's,/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf \
    && sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf \
# nginx user must own the cache and etc directory to write cache and tweak the nginx config
    #&& chown -R $UID:0 /var/cache/nginx \
    #&& chmod -R g+w /var/cache/nginx \
    && chown -R $UID:0 /etc/nginx \
    && chmod -R g+w /etc/nginx \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
    #&& chown -R $UID:0 /var/log/nginx \
    #&& chmod -R g+w /var/log/nginx

# set timezone
RUN if [ ! -z "${TZ}" ]; then ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && echo "${TZ}" > /etc/timezone; fi

#VOLUME /etc/nginx/certs
#ENV PATH="/opt/bitnami/common/bin:/opt/bitnami/nginx/sbin:$PATH"

EXPOSE 8080/tcp
EXPOSE 8443/tcp

WORKDIR /app

USER $UID
ENTRYPOINT [ "/opt/keeper/nginx/entrypoint.sh" ]
CMD [ "/opt/keeper/scripts/run.sh" ]
