#! /bin/bash

config_dir=/service-config/config

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# same .bashrc as jupyter service
bashrc=/config/workspace/.bashrc
[[ -f ${bashrc} ]] && rsync -a ${bashrc} ~

# device environment (e.g. DNS_NAME)
env_file=${config_dir}/config/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

# (conditionally) mount $HOME
sudo /bin/bash -c "HOME=${HOME}; source ${config_dir}/bin/samba-mount"

# Note: /config/custom-cont-init.d executed (if it exists) when code-server starts

sleep infinity
