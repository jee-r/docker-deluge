FROM emmercm/libtorrent:2.0.4-alpine

LABEL name="docker-deluge" \
      maintainer="Jee jee@eer.fr" \
      description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
      url="https://deluge-torrent.org/" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge" \
      org.opencontainers.image.source="https://github.com/jee-r/docker-deluge"

COPY rootfs /

ENV PYTHON_EGG_CACHE=/config/.cache

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --virtual=base --upgrade \
        bash \
        p7zip \
        unrar \
        unzip \
        git \
        tzdata \
        ca-certificates \
        curl && \
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
    python3 -m ensurepip --upgrade && \
    git clone git://deluge-torrent.org/deluge.git /tmp/deluge && \
    cd /tmp/deluge && \
    pip3 --timeout 40 --retries 10  install --no-cache-dir --upgrade  \
        wheel \
        pip \
        six==1.16.0 && \
    pip3 --timeout 40 --retries 10 install --no-cache-dir --upgrade --requirement requirements.txt && \
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/* && \
    ln -sf /config /.config

WORKDIR /config

VOLUME ["/config"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
    CMD /usr/local/bin/healthcheck.sh 58846 8112

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
