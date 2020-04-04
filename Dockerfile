FROM alpine:3.11
LABEL "Maintainer"="Jee <jee@eer.fr>"

ENV uid=1026 \
    gid=65536

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
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
    #wget http://download.deluge-torrent.org/source/2.0/deluge-2.0.3.tar.xz && \
    #tar -xf deluge-2.0.3.tar.xz && \
    #cd deluge-2.0.3 && \
    git clone git://deluge-torrent.org/deluge.git && \
    cd deluge && \
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    cd / && \
    rm -rf deluge && \
    # Change `users` gid to match the passed in $gid
    [ $(getent group users | cut -d: -f3) == $gid ] || \
            sed -i "s/users:x:[0-9]\+:/users:x:$gid:/" /etc/group && \
    adduser -h /config -DG users -u $uid deluge && \
    echo "deluge:deluge" | chpasswd && \
    mkdir /data && \
    chown -R deluge:users /config /data && \
    apk del build-base \
            libffi-dev \
            libjpeg-turbo-dev \
            linux-headers \
            python3-dev \
            zlib-dev

COPY entrypoint.sh /usr/local/bin/

USER deluge

VOLUME ["/config"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
