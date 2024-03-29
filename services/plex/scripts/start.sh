#!/bin/bash

# container does not have the balena ENTRYPOINT entry.sh
/bin/bash -c "UDEV=ON; source /usr/src/scripts/balena-entry.sh"

# mount usb devices that are already connected
sleep 1   # race condition

for DISK in `lsblk -o KNAME | egrep sd[a-z][0-9]`
do
    echo "Mount /dev/$DISK"
    /bin/sh -c "/usr/src/scripts/mount.sh /dev/$DISK"
done

# Prevent container from exiting
sleep infinity
