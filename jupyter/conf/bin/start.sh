#!/bin/bash

# start.sh runs as root
iot_home=/service-config/iot-home

# set home folder ownership
chown ${NB_UID}:${NB_GID} ${iot_home}
chown ${NB_UID}:${NB_GID} /home/${NB_USER}

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# device environment; applies to all services
rsync --ignore-existing -a --chown iot:users /usr/local/scripts/ ${iot_home}
env_file=/service-config/config/.env
if [[ -f ${env_file} ]]; then
    set -a; source ${env_file}; set +a
fi

# Enable dynamically plugged devices (/dev). Requires privileged container.
/bin/bash -c "UDEV=${UDEV:-off}; source /usr/local/bin/balena-entry.sh"

# Add ${CONDA_DIR}/bin to sudo secure_path (from official jupyter docker start.sh)
sed -r "s#Defaults\s+secure_path\s*=\s*\"?([^\"]+)\"?#Defaults secure_path=\"\1:${CONDA_DIR}/bin\"#" /etc/sudoers | grep secure_path > /etc/sudoers.d/path

# per container startup (set in derived container if needed); runs as root
start_hook="/usr/local/bin/start-hook.sh"
[[ -f ${start_hook} ]] && source ${start_hook}

# (conditionally) mount $HOME
/bin/bash -c "HOME=${HOME}; source /usr/local/bin/samba-mount.sh"

# user startup (don't run as root!)
service_rc="${HOME}/.${BALENA_SERVICE_NAME}-rc.sh"
[[ -f ${service_rc} ]] && setuidgid ${NB_USER} /bin/bash ${service_rc}

echo JUPYTER_PORT ${JUPYTER_PORT}

echo setuidgid ${NB_USER} \
  jupyter lab --no-browser --allow-root \
    --ServerApp.ip=${JUPYTER_IP:='*'} \
    --ServerApp.port=${JUPYTER_PORT:=8888} \
    --ServerApp.token="" --ServerApp.password=""

# run jupyter as user 'iot'
setuidgid ${NB_USER} \
  jupyter lab --no-browser --allow-root \
    --ServerApp.ip=${JUPYTER_IP:='*'} \
    --ServerApp.port=${JUPYTER_PORT:=8888} \
    --ServerApp.token="" --ServerApp.password=""