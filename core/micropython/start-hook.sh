#! /bin/bash

# set permissions for gpio as non-root user (gpio group)
# no gpiomem on amd64
if [ -e /dev/gpiomem ]; then
    sudo -s -- <<EOF
        chown root.gpio /dev/gpiomem
        chmod g+rw /dev/gpiomem
        chown root.gpio /sys/class/gpio/*export
        chmod ug+rwx /sys/class/gpio/*export
EOF
fi

# template for customizing device environment
env49rc=/service-config/iot-home/.env49rc
if [ ! -f $env49rc ]; then
    cp /usr/local/src/env49rc.default $env49rc
    chmod a+x $env49rc
fi
