FROM alpine:3.21 AS unrar-builder
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


FROM emmercm/libtorrent:2.0.10-alpine

LABEL name="docker-deluge" \
    maintainer="Jee jee@eer.fr" \
    description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
    url="https://deluge-torrent.org/" \
    org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge" \
    org.opencontainers.image.source="https://github.com/jee-r/docker-deluge"

COPY rootfs /
COPY --from=unrar-builder /tmp/unrar/unrar /tmp/unrar

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
        python3 && \
    apk add --no-cache --virtual=build-dependencies --upgrade \
        build-base \
        libffi-dev \
        zlib-dev \
        openssl-dev \
        libjpeg-turbo-dev \
        linux-headers \
        musl-dev \
        cargo \
        python3-dev && \
    apk add --no-cache --virtual=deluge-dependencies --upgrade \
        py3-chardet \
        py3-distro \
        py3-idna \
        py3-mako \
        py3-openssl \
        py3-pillow \
        py3-rencode \
        py3-service_identity \
        py3-setproctitle \
        py3-setuptools \
        py3-twisted \
        py3-wheel \	
        py3-xdg \
        py3-six \
        py3-zope-interface && \
    install -v -m755 /tmp/unrar /usr/local/bin && \
    git clone -b develop git://deluge-torrent.org/deluge.git /tmp/deluge && \
    cd /tmp/deluge && \
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

WORKDIR /config

VOLUME ["/config"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
    CMD /usr/local/bin/healthcheck.sh 58846 8112

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]