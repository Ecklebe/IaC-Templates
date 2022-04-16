FROM ubuntu:focal-20200423

ENV BIND_USER=bind \
    BIND_VERSION=9.16.1 \
    DATA_DIR=/data

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg1 wget \
    && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list \
    && wget -q -O- http://www.webmin.com/jcameron-key.asc | apt-key add \
    && rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin\
    && apt-get update \
    && apt-get upgrade -y\
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]


