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
