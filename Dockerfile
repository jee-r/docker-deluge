FROM alpine:3.12

LABEL name="docker-deluge" \
      maintainer="Jee jee@eer.fr" \
      description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
      url="https://deluge-torrent.org/" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk --no-cache add build-base \
      ca-certificates \
      libffi-dev \
      libjpeg-turbo-dev \
      linux-headers \
      p7zip \
      py3-libtorrent-rasterbar \
      py3-openssl \
      py3-pip \
      python3-dev \
      unrar \
      unzip \
      git \
      bash \
      zlib-dev \
      tzdata && \
    git clone git://deluge-torrent.org/deluge.git && \
    cd deluge && \
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    cd / && \
    rm -rf deluge && \
    apk del build-base \
            libffi-dev \
            libjpeg-turbo-dev \
            linux-headers \
            python3-dev \
            zlib-dev

WORKDIR /config

COPY entrypoint.sh /usr/local/bin/

VOLUME ["/config"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]