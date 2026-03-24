# Debian Bookworm
FROM bitnami/minideb:bookworm

#LABEL authors="Artyom Yudin" \
#      org.opencontainers.image.base.name="docker.io/artyomyudin/nginx:1.22.1-9" \
#      org.opencontainers.image.created="" \
#      org.opencontainers.image.description="NGINX Application packaged by Keeper" \
#      org.opencontainers.image.documentation="https://github.com/ArtyomYudin/containers/tree/main/nginx/README.md" \
#      org.opencontainers.image.licenses="Apache-2.0" \
#      org.opencontainers.image.ref.name="1.22.1-debian-12-r0" \
#      org.opencontainers.image.source="https://github.com/ArtyomYudin/containers/tree/main/nginx" \
#      org.opencontainers.image.title="nginx" \
#      org.opencontainers.image.vendor="" \
#      org.opencontainers.image.version="1.21.1-9"



SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

ENV PORT=443
ENV WORKERS=1

RUN apt-get update && apt-get install -y \
    git curl xxd openssl ca-certificates \
    build-essential libssl-dev zlib1g-dev tini \
    && rm -rf /var/lib/apt/lists/*

# build MTProxy
RUN git clone https://github.com/TelegramMessenger/MTProxy /opt/MTProxy && \
    make -C /opt/MTProxy && \
    cp /opt/MTProxy/objs/bin/mtproto-proxy /usr/local/bin/mtproto-proxy

# directories
RUN mkdir -p /etc/mtproxy /var/lib/mtproxy

# entrypoint
COPY entrypoint.sh /entrypoint.sh
COPY updater.sh /updater.sh
RUN chmod +x /entrypoint.sh /updater.sh

EXPOSE 443 8888

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/entrypoint.sh"]