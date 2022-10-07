#!/bin/bash

# start.sh runs as user iot
iot_home=/service-config/iot-home

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# device environment (e.g. DNS_NAME); applies to all services
rsync --ignore-existing -a --chown iot:users /usr/local/scripts/ ${iot_home}
set -a; source ${iot_home}/.env; set +a

# Enable dynamically plugged devices (/dev). Requires privileged container.
sudo /bin/bash -c "UDEV=${UDEV:-off}; source /usr/local/bin/balena-entry.sh"

# Add ${CONDA_DIR}/bin to sudo secure_path (from official jupyter docker start.sh)
sudo su - << EOF
   sed -r "s#Defaults\s+secure_path\s*=\s*\"?([^\"]+)\"?#Defaults secure_path=\"\1:${CONDA_DIR}/bin\"#" /etc/sudoers | grep secure_path > /etc/sudoers.d/path
EOF

# per container startup (set in derived container if needed)
start_hook="/usr/local/bin/start-hook.sh"
[[ -f ${start_hook} ]] && source ${start_hook}

# (conditionally) mount $HOME
sudo /bin/bash -c "HOME=${HOME}; source /usr/local/bin/samba-mount.sh"

# user startup
service_rc="${HOME}/.${BALENA_SERVICE_NAME}-rc.sh"
[[ -f ${service_rc} ]] && source ${service_rc}


# Jupyter file location issues:
#   1) $HOME may be cifs mounted --> store config on ${iot_home}
#   2) We are running multiple servers - does some data need to be kept separate?
#      - place NotebookNotary.db_file in per-service location, not sure it's required
#      - ditto for runtime
# https://jupyter.readthedocs.io/en/latest/use/jupyter-directories.html

jupyter_config=${iot_home}/.config-jupyter/$BALENA_SERVICE_NAME
mkdir -p ${jupyter_config}
chown -R ${NB_UID}:${NB_GID} ${jupyter_config}

# don't share config between services (?)
export JUPYTER_CONFIG_DIR=${jupyter_config}/.jupyter
# export JUPYTER_CONFIG_DIR=${iot_home}/.jupyter

# kernelspec, default: ~/.local/share/jupyter/
export JUPYTER_PATH=${jupyter_config}/.local

# separate runtime directory for each service
export JUPYTER_RUNTIME_DIR=${jupyter_config}

# sqlite database
export IPYTHONDIR=${jupyter_config}/.ipython

# run jupyter as user 'iot'
setuidgid ${NB_USER} \
  jupyter lab --no-browser --allow-root \
    --ServerApp.ip=${JUPYTER_IP:='*'} \
    --ServerApp.port=${JUPYTER_PORT:=8888} \
    --ServerApp.token="" --ServerApp.password="" \
    --NotebookNotary.db_file="${jupyter_config}/sqlite_db_file.lock"
