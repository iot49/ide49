#! /bin/bash

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# same .bashrc as jupyter service
rsync -a /service-config/iot-home/.bashrc /config/workspace/

# device environment (e.g. DNS_NAME)
env_file=/service-config/iot-home/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

# (conditionally) mount $HOME
sudo /bin/bash -c "HOME=/config/workspace/; source /usr/local/bin/samba-mount.sh"

# Note: /config/custom-cont-init.d executed (if it exists) when code-server starts

sleep infinity
