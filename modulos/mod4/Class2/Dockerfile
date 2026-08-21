FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server sudo && \
    mkdir /var/run/sshd

# Crear usuario adminlab
RUN useradd -rm -d /home/adminlab -s /bin/bash -g root -G sudo adminlab

# Copiar el script de inicio
COPY entrypoint.sh /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]

