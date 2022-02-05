#!/bin/sh
umask 002
sleep 15 && \
deluge-web -L $LOGLEVEL --config /config
deluged -d -L $LOGLEVEL --config /config
