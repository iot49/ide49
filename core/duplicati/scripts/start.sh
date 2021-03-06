#!/bin/bash

# duplicati container does not have the balena ENTRYPOINT entry.sh
# this seems to do the trick ...
/bin/bash /usr/src/scripts/entry.sh

# mount usb devices that are already connected
sleep 1   # race condition

for DISK in `lsblk -o KNAME | egrep sd[a-z][0-9]`
do
    echo "Mount /dev/$DISK"
    /bin/sh -c "/usr/src/scripts/mount.sh /dev/$DISK"
done

# Prevent container from exiting
sleep infinity
