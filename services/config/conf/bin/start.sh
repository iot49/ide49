#!/bin/bash

# default configuration
config=/service-config/config
chown -R 0:100 ${config}
cd ${config}
rsync --ignore-existing -a --chown 0:100 /usr/local/config/ .

# .env
sed -i '/^HOST_IP=/d' .env
echo HOST_IP=`ip route | awk '{print $3}' | head -n 1` >> .env

set -a; source .env; set +a

# enable bluetooth for uid 1000
source /usr/local/bin/configure-bluetooth.sh

# ${config}/.nginx /.nginx 
python /usr/local/src/app.py

# cat ${config}/.nginx 

sleep infinity
