FROM alpine:3.20

# Устанавливаем необходимые пакеты (добавили openssl!)
RUN apk add --no-cache openssh-server openssh-sftp-server openssl

RUN adduser -D -u 1001 -g 1001 admin && \
    mkdir -p /home/admin/upload && \
    chown -R admin:admin /home/admin/upload

RUN ssh-keygen -A && \
    chown -R admin:admin /etc/ssh/ssh_host_*_key

# Базовые настройки SSH
RUN echo "Port 2222" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config && \
    echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config && \
    echo "UsePAM no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config

RUN echo "" >> /etc/ssh/sshd_config && \
    echo "Match User admin" >> /etc/ssh/sshd_config && \
    echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config && \
    echo "    PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Теперь openssl доступен
RUN PASSWORD_HASH=$(openssl passwd -1 "4YyeeuFj6trJ") && \
    sed -i "s|^admin:.*|admin:${PASSWORD_HASH}:1001:1001:Linux User:/home/admin:/sbin/nologin|" /etc/passwd && \
    chmod 644 /etc/passwd

RUN mkdir -p /home/admin/run && chown admin:admin /home/admin/run

USER 1001
EXPOSE 2222

CMD ["/usr/sbin/sshd", "-D", "-e", "-p", "2222", "-o", "PidFile=/home/admin/run/sshd.pid"]