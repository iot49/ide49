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

# reboot & shutdown links missing on newer versions of Ubuntu
# ln -f -s -- ../bin/systemctl /sbin/reboot
# ln -f -s -- ../bin/systemctl /sbin/shutdown

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


# Jupyter file location issues:
#   1) $HOME is shared by multiple containers and could further be smb mounted or shared (syncthing) 
#      - per service ($BALENA_SERVICE_NAME) config
#      - store locally on /service-config/iot-home (which is not mounted)
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

printenv

# sqlite database
export IPYTHONDIR=${jupyter_config}/.ipython# run jupyter as user 'iot'
setuidgid ${NB_USER} \
  jupyter lab --no-browser --allow-root \
    --ServerApp.ip=${JUPYTER_IP:='*'} \
    --ServerApp.port=${JUPYTER_PORT:=8888} \
    --ServerApp.token="" --ServerApp.password="" \
    --NotebookNotary.db_file="${jupyter_config}/sqlite_db_file.lock"
