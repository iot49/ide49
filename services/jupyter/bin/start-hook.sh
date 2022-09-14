#! /bin/bash

echo "START HOOK --------------------------------------------------------------"

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

echo "enable bluetooth --------------------------------------------------------"
# enable bluetooth for user iot
# adds user iot and patches /etc/dbus-1/system.d/bluetooth.conf on Host OS
/usr/local/bin/enable-bluetooth.sh

echo "start-hook.sh DONE! -----------------------------------------------------"
