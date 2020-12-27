FROM emmercm/libtorrent:1-alpine

LABEL name="docker-deluge" \
      maintainer="Jee jee@eer.fr" \
      description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
      url="https://deluge-torrent.org/" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge"

ENV PYTHON_EGG_CACHE=/config/.cache

RUN sed -i 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.ircam.fr\/pub/' /etc/apk/repositories && \
    echo "nameserver 9.9.9.9" > /etc/resolv.conf && \
    apk update && \
    apk upgrade && \
    apk add --no-cache --virtual=base --upgrade \
        bash \
        p7zip \
        unrar \
        unzip \
        git \
        tzdata && \
    apk add --no-cache --virtual=build-dependencies --upgrade \
        build-base \
        libffi-dev \
        zlib-dev \
        openssl-dev \
        libjpeg-turbo-dev \
        linux-headers \
        python3-dev && \
    apk --no-cache --upgrade add \
        ca-certificates \
        py3-pip && \
    git clone git://deluge-torrent.org/deluge.git /tmp/deluge && \
    cd /tmp/deluge && \
    pip3--timeout 40 --retries 10  install --no-cache-dir --upgrade  \
        wheel \
        pip && \
    pip3 --timeout 40 --retries 10 install --no-cache-dir --upgrade --requirement requirements.txt
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

WORKDIR /config

COPY entrypoint.sh /usr/local/bin/
COPY healthcheck.sh /usr/local/bin/

VOLUME ["/config"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
CMD /usr/local/bin/healthcheck.sh 58846 8112

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
