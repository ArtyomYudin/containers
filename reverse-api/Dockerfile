FROM bitnami/minideb:jessie

#LABEL authors="Artyom Yudin" \
#      org.opencontainers.image.base.name="docker.io/artyomyudin/php-fpm:5.3.29" \
#      org.opencontainers.image.created="" \
#      org.opencontainers.image.description="Legacy PHP-FPM Application packaged by Keeper" \
#      org.opencontainers.image.documentation="https://github.com/ArtyomYudin/containers/tree/main/php-fpm/README.md" \
#      org.opencontainers.image.licenses="Apache-2.0" \
#      org.opencontainers.image.ref.name="5.3.29-debian-12-r0" \
#      org.opencontainers.image.source="https://github.com/ArtyomYudin/containers/tree/main/php-fpm" \
#      org.opencontainers.image.title="php-fpm" \
#      org.opencontainers.image.vendor="" \
#      org.opencontainers.image.version="5.3.29"


SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]


COPY rootfs-apt/sources.list /etc/apt/

RUN printf 'Acquire::Check-Valid-Until "false";\n\
Acquire::AllowInsecureRepositories "true";\n\
Acquire::AllowDowngradeToInsecureRepositories "true";\n\
APT::Get::AllowUnauthenticated "true";\n' \
> /etc/apt/apt.conf.d/99legacy


# Install packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install vim libqt4-sql-ibase libqt4-network -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

#
#

COPY reverse/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /opt/reverse-api

COPY reverse/ReverseApiServer /opt/reverse-api/
RUN chmod +x /opt/reverse-api/ReverseApiServer


#COPY rootfs-systemd/reverse-api.service /etc/systemd/system/
#RUN systemctl daemon-reload
#RUN systemctl enable reverse-api.service
#RUN systemctl start myapp.service


EXPOSE 22564/TCP
EXPOSE 24532/TCP
#WORKDIR /app


ENTRYPOINT ["/opt/reverse-api/ReverseApiServer", "-e"]


