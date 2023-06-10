FROM alpine:3.17 AS unrar-builder
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


FROM alpine:3.17 AS libtorrent-builder

ARG VERSION=2.0.[0-9]\\+

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# Build libtorrent-rasterbar-dev
# hadolint ignore=DL3003,DL3018,SC2086
RUN apk --update add --no-cache --upgrade                               boost-python3 boost-system libgcc libstdc++ openssl python3 && \
    apk --update add --no-cache --upgrade --virtual build-dependencies  boost-build boost-dev cmake coreutils g++ gcc git jq py3-setuptools python3-dev openssl-dev samurai && \
    # Checkout from source
    cd "$(mktemp -d)" && \
    git clone --branch "$( \ 
         wget -qO - https://api.github.com/repos/arvidn/libtorrent/tags?per_page=100 | jq -r '.[].name' | \
         awk '{print $1" "$1}' | \
         # Get rid of prefixes
         sed 's/^libtorrent[^0-9]//i' | \
         sed 's/^v//i' | \
         # Use periods for major.minor.patch
         sed 's/[^a-zA-Z0-9.]\([0-9]\+.* .*\)/.\1/g' | \
         sed 's/[^a-zA-Z0-9.]\([0-9]\+.* .*\)/.\1/g' | \
         # Make sure patch version exists
         sed 's/^\([0-9]\+\.[0-9]\+\)\([^0-9.].\+\)/\1.0\2/' | \
         # Get the right version
         sort --version-sort --key=1,1 | \
         grep "${VERSION}" | \
         tail -1 | \
         awk '{print $2}' \
     )" --depth 1 https://github.com/arvidn/libtorrent.git && \
    cd libtorrent && \
    git clean --force && \
    git submodule update --depth=1 --init --recursive && \
    mkdir /libtorrent-build && \
    # Run b2
    PREFIX=/usr && \
    export BOOST_BUILD_PATH=$(dirname $(find ${PREFIX} -type f -name bootstrap.jam | head -1)) && \
    export BOOST_ROOT="" && \
    BUILD_CONFIG="release cxxstd=14 crypto=openssl warnings=off address-model=32 -j$(nproc)" && \
    b2 ${BUILD_CONFIG} link=shared install --prefix=${PREFIX} && \
    b2 ${BUILD_CONFIG} link=static install --prefix=${PREFIX} && \
    cd bindings/python && \
    PYTHON_MAJOR_MINOR="$(python3 --version 2>&1 | sed 's/\(python \)\?\([0-9]\+\.[0-9]\+\)\(\.[0-9]\+\)\?/\2/i')" && \
    echo "using python : ${PYTHON_MAJOR_MINOR} : $(command -v python3) : /usr/include/python${PYTHON_MAJOR_MINOR} : /usr/lib/python${PYTHON_MAJOR_MINOR} ;" > ~/user-config.jam && \
    b2 ${BUILD_CONFIG} install_module python-install-scope=system && \
    # Remove temp files
    cd && \
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

FROM alpine:3.17

LABEL name="docker-deluge" \
      maintainer="Jee jee@eer.fr" \
      description="Deluge is a lightweight, Free Software, cross-platform BitTorrent client." \
      url="https://deluge-torrent.org/" \
      org.label-schema.vcs-url="https://github.com/jee-r/docker-deluge" \
      org.opencontainers.image.source="https://github.com/jee-r/docker-deluge"

COPY rootfs /
COPY --from=unrar-builder /tmp/unrar/unrar /tmp/unrar
COPY --from=libtorrent-builder /usr /usr

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
        curl && \
    apk add --no-cache --virtual=libtorrent-deps --upgrade \
        boost-python3 \
        boost-system \
        libgcc \
        libstdc++ \
        openssl \
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
    install -v -m755 /tmp/unrar /usr/local/bin && \
    rm -rf /tmp/*

WORKDIR /config

VOLUME ["/config"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
    CMD /usr/local/bin/healthcheck.sh 58846 8112

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
