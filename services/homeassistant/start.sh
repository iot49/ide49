#! /bin/bash

# Mount dynamically plugged devices (/dev). Requires privileged container.
/bin/bash -c "UDEV=${UDEV:-on}; source /usr/local/bin/balena-entry.sh"

# Don't run as root & set user "iot" to "inherit" bluetooth access from jupyter service
# https://community.home-assistant.io/t/improving-docker-security-non-root-configuration/399971
# https://github.com/tribut/homeassistant-docker-venv

source /usr/local/bin/run

# Link secrets.yaml

secrets_src=/service-config/iot-home/.secrets.yaml
secrets_dst=/service-config/homeassistant/secrets.yaml
if [ ! -L ${secrets_dst} ]; then
    rm -f ${secrets_dst}
    ln -s ${secrets_src} ${secrets_dst}
fi

