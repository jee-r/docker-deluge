#!/bin/sh
umask 002
sleep 15 && \
deluge-web -L info --config /config
deluged -d -L info --config /config
