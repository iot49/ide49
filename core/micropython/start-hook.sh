#! /bin/bash

echo "START HOOK -----------------------------------------------------------------------------"

# set permissions for gpio as non-root user (gpio group)
# no gpiomem on amd64
if [ -e /dev/gpiomem ]; then
    echo "configure gpiomem"
    sudo -s -- <<EOF
        chown root.gpio /dev/gpiomem
        chmod g+rw /dev/gpiomem
        chown root.gpio /sys/class/gpio/*export
        chmod ug+rwx /sys/class/gpio/*export
EOF
fi

echo "set host IP -------------------------------------------------------------"

# set ${HOST_IP}
while [ -z ${HOST_IP} ]; do
    export HOST_IP=$(curl -s -X GET --header "Content-Type:application/json" \
            "$BALENA_SUPERVISOR_ADDRESS/v1/device?apikey=$BALENA_SUPERVISOR_API_KEY" | \
            jq -r ".ip_address")
    echo IP ${HOST_IP}
done

echo "envrc template -------------------------------------------------------------"

# template for customizing device environment
env49rc=/service-config/iot-home/.env49rc
if [ ! -f $env49rc ]; then
    cp /usr/local/src/env49rc.default $env49rc
    chmod a+x $env49rc
fi

echo "enable bluetooth -------------------------------------------------------------"
# enable bluetooth for user iot
# adds user iot and patches /etc/dbus-1/system.d/bluetooth.conf on Host OS
enable-bluetooth

echo "start-hook.sh DONE! -------------------------------------------------------------"