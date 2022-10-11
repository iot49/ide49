#!/bin/bash

echo SERVICES   -$SERVICES-
echo VOLUMES    -$VOLUMES-
echo HTTP_PORTS -$HTTP_PORTS-

# default configuration
config=/service-config/config
echo chown -R 0:100 ${config}
chown -R 0:100 ${config}
cd ${config}
rsync --ignore-existing -a --chown 0:100 /usr/local/config/ .

# .env
sed -i '/^HOST_IP=/d' .env
echo HOST_IP=`ip route | awk '{print $3}' | head -n 1` >> .env

set -a; source .env; set +a

# enable bluetooth for uid 1000
source /usr/local/bin/configure-bluetooth.sh

# nginx configuration

python /usr/local/src/app.py

sleep infinity
