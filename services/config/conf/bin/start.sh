#!/bin/bash

# default configuration
config=/service-config/config
chown -R 0:100 ${config}
cd ${config}
rsync --ignore-existing -a --chown 0:100 /usr/local/config/ .

# .env
sed -i '/^HOST_IP=/d' .env
echo HOST_IP=`ip route | awk '{print $3}' | head -n 1` >> .env

if ! grep -q "MDNS_DOMAIN=" ".env"; then
  echo add ide49
  echo MDNS_DOMAIN=ide49 >> .env
fi

set -a; source .env; set +a

# enable bluetooth for uid 1000
source /usr/local/bin/configure-bluetooth.sh

# set hostname = MDNS_NAME
if [ -z $BALENA_SUPERVISOR_ADDRESS ]; then
  HOST_NAME=$(curl -s -X GET --header "Content-Type:application/json" \
            "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY" | \
            jq ".network.hostname")
  HOST_NAME="${HOST_NAME%\"}"
  HOST_NAME="${HOST_NAME#\"}"

  if [[ $HOST_NAME != $MDNS_DOMAIN ]]; then
      echo changing hostname from $HOST_NAME to $MDNS_DOMAIN
      curl -X PATCH --header "Content-Type:application/json" \
          --data '{"network": {"hostname": "'"$MDNS_DOMAIN"'" } }' \
          "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"
  fi
fi

sleep infinity