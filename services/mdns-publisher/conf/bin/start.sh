#! /bin/bash

export HOST_NAME=$(curl -s -X GET --header "Content-Type:application/json" \
           "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY" | \
           jq ".network.hostname")
HOST_NAME="${HOST_NAME%\"}"
HOST_NAME="${HOST_NAME#\"}"

python /etc/local/src/app.py