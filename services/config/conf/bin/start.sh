#!/bin/bash

# default configuration
config=/service-config/config
chown -R 1000:100 /service-config/config
cd /service-config/config
rsync --ignore-existing -a --chown 1000:100 /usr/local/config/ .
chmod -R a+x bin

# Set correct values in .env:
#    HOST_IP:      ip of host container
#    NGINX_IP:     local ip of nginx service
#    MDNS_DOMAIN:  defaults to ide49 if not set in .env
sed -i '/^HOST_IP=/d' .env
echo HOST_IP=`ip route | awk '{print $3}' | head -n 1` >> .env

sed -i '/^NGINX_IP=/d' .env
echo NGINX_IP=`dig +short nginx` >> .env

if ! grep -q "MDNS_DOMAIN=" ".env"; then
  echo MDNS_DOMAIN=ide49 >> .env
fi

# remove next line
sed -i '/^IP=/d' .env
# if nc -zw1 google.com 443 && [ ! -z $BALENA_SUPERVISOR_ADDRESS ]; then
#     HOST_NAME=$(curl -s -X GET --header "Content-Type:application/json" \
#           "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY" | \
#           jq ".network.hostname")
#     HOST_NAME="${HOST_NAME%\"}"
#     HOST_NAME="${HOST_NAME#\"}"
# 
#     IP=$(curl -s -X GET --header "Content-Type:application/json" \
#         "$BALENA_SUPERVISOR_ADDRESS/v1/device?apikey=$BALENA_SUPERVISOR_API_KEY" \
#       | jq -r ".ip_address" \
#       | awk '{print $1;}')
#     echo IP=${IP} >> .env
# else
#     echo WARNING: offline - cannot check & set HOST_NAME
# fi

set -a; source .env; set +a

# enable bluetooth for uid 1000
source /usr/local/bin/configure-bluetooth.sh

# REMOVE - don't use internet in start.sh
# 
# set HOST_NAME = MDNS_NAME
# Notes: 
#    - works only if online
#    - `hostname` has a different value (?)
# if [[ ! -z $HOST_NAME && $HOST_NAME != ${MDNS_DOMAIN:=ide49} ]]; then
#     echo INFO: changing hostname from $HOST_NAME to $MDNS_DOMAIN
#     curl -X PATCH --header "Content-Type:application/json" \
#         --data '{"network": {"hostname": "'"$MDNS_DOMAIN"'" } }' \
#         "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"
# fi

sleep infinity