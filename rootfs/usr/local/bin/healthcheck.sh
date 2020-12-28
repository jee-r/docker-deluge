#!/bin/sh

DEAMON_PORT="$1"
WEB_PORT="$2"

if [ "$(netstat -plnt | grep -c $DEAMON_PORT)" -eq 1 ]; then
   echo "Deluge daemon [$DEAMON_PORT] : OK"
else
  echo "Deluge daemon [$DEAMON_PORT] : NOK"
  exit 1
fi

if [ "$(netstat -plnt | grep -c $WEB_PORT)" -eq 1 ]; then
   echo "Deluge daemon [$WEB_PORT] : OK"
else
  echo "Deluge daemon [$WEB_PORT] : NOK"
fi
exit 0
