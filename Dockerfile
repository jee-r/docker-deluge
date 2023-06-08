FROM alpine:3.18 AS builder-unrar
WORKDIR /tmp

ARG UNRAR_VERSION=6.1.5

RUN apk update && \
    apk add --no-cache \
        curl \
        tar \
        gzip \
        make \
        g++ && \
    mkdir -p /tmp/unrar && \
    curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \  
    tar xf \
        /tmp/unrar.tar.gz -C \
        /tmp/unrar --strip-components=1 && \
    cd /tmp/unrar && \
    make 

FROM alpine:3.18
LABEL name="docker-deluge" \
      maintainer="Jee jee@eer.fr" \
      description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
      url="https://deluge-torrent.org/" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge" \
      org.opencontainers.image.source="https://github.com/jee-r/docker-deluge"

COPY rootfs /
COPY --from=builder-unrar /tmp/unrar/unrar /tmp/unrar

ENV PYTHON_EGG_CACHE=/config/.cache \
    XDG_CONFIG_HOME=/config \
    LOGLEVEL=info

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --virtual=base --upgrade \
        bash \
        p7zip \
        unzip \
        git \
        tzdata \
        ca-certificates \
        curl \
	deluge && \
    install -v -m755 /tmp/unrar /usr/local/bin && \
    rm -rf /tmp/*

WORKDIR /config

VOLUME ["/config"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
    CMD /usr/local/bin/healthcheck.sh 58846 8112

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
