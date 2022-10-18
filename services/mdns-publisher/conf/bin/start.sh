#! /bin/bash

# load environment
env_file=/service-config/config/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

echo DBUS_SYSTEM_BUS_ADDRESS=${DBUS_SYSTEM_BUS_ADDRESS}

python /etc/local/src/app.py