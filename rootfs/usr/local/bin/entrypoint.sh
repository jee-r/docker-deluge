#!/bin/sh
if [[ -z "${LOGLEVEL}" ]]; then
  LOGLEVEL="info"
else
  LOGLEVEL="${LOGLEVEL}"
fi
umask 002
sleep 15 && \
deluge-web -L $LOGLEVEL --config /config
deluged -d -L $LOGLEVEL --config /config
