#!/bin/bash

# syncthing needs /service-config writeable
chown :100 /service-config
chmod g+w /service-config

sleep infinity
