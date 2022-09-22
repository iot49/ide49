#! /bin/bash

# Mount dynamically plugged devices (/dev). Requires privileged container.
/bin/bash -c "UDEV=${UDEV:-on}; source /usr/local/bin/balena-entry.sh"

# Start esphome
dashboard /config
