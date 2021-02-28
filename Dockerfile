FROM alpine:3.12

LABEL name="docker-deluge" \
      maintainer="Jee jee@eer.fr" \
      description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
      url="https://deluge-torrent.org/" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge"

ARG LIBTORRENT_VERSION=v1.2.11
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
        tzdata && \
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
    apk --no-cache --upgrade add \
        ca-certificates \
        py3-pip && \
    apk add --no-cache --virtual=libtorrent-base-dependencies --upgrade \
        boost-system \
        libgcc \
        libstdc++ \
        openssl \
        python3 \
        boost-python3 && \
    apk add --no-cache --virtual=libtorrent-build-dependencies --upgrade \
        autoconf \
        automake \
        boost-dev \
        coreutils \
        file \
        g++ \
        gcc \
        git \
        libtool \
        make \
        openssl-dev \
        python3-dev && \
    git clone https://github.com/arvidn/libtorrent.git /tmp/libtorrent && \
    cd /tmp/libtorrent && \
    git checkout ${LIBTORRENT_VERSION} && \
    git clean --force && \
    git submodule update --depth=1 --init --recursive && \
    git apply /5026.patch && rm /5026.patch && \
    ./autotool.sh && \
    ./configure \
        --prefix=/usr \
        --with-libiconv \
        --enable-python-binding \
        --with-boost-python="$(find /usr/lib -maxdepth 1 -name "libboost_python3*.so*" | sort | head -1 | sed 's/.*.\/lib\(.*\)\.so.*/\1/')" \
        --with-cxx-standard=14 \
        PYTHON="$(which "python3")" && \
    make "-j$(nproc)" && \
    make install-strip && \
    git clone git://deluge-torrent.org/deluge.git /tmp/deluge && \
    cd /tmp/deluge && \
    pip3 install --no-cache-dir --upgrade \
        wheel \
        setuptools \
        pip && \
    pip3 install --no-cache-dir --upgrade --requirement requirements.txt && \
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    apk del --purge build-dependencies libtorrent-build-dependencies && \
    rm -rf /tmp/*

WORKDIR /config

VOLUME ["/config"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
    CMD /usr/local/bin/healthcheck.sh 58846 8112

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
