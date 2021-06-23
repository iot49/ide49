#!/bin/bash

sleep_forever () {
    while : ; do
        # echo "idling ..."
        sleep 600
    done
}


# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# conditionally mount /home/iot
if [[ ${SAMBA:=off} == client ]]; then
    sudo mkdir -p ${HOME}
    # keep trying
    while true
    do
        sudo mount -t cifs //${SAMBA_SERVER_IP}/iot-data ${HOME} \
            -ouid=1000,gid=1000,username=iot,password=${SAMBA_PASSWORD},sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
fi


# echo "sleep forever"
sleep_forever

# Start jupyter ...

# store custom lab extensions in user writable folder
# https://jupyterlab.readthedocs.io/en/latest/user/directories.html
export JUPYTERLAB_DIR=/home/iot/.jupyter-balena-cli

# fix runtime file permissions issue
# https://github.com/jupyter/notebook/issues/5058
export JUPYTER_RUNTIME_DIR="${JUPYTER_RUNTIME_DIR:=/service-config/iot-home/.local/share/jupyter/runtime}"

# never save config (especially sqlite history lock) to samba share
# history lock ERROR: https://gitter.im/ipython/ipython/help/archives/2017/04/20
mkdir -p /service-config/iot-home/.ipython-balena-cli
export IPYTHONDIR="${IPYTHONDIR:=/service-config/iot-home/.ipython-balena-cli}"

# never save sqlite lock on samba share!
jupyter lab --ip='172.17.0.1' --port=8898 --no-browser \
    --ServerApp.base_url='/balena-cli' \
    --ServerApp.token='' --ServerApp.password='' \
    --NotebookNotary.db_file='/service-config/iot-home/.ipython-balena-cli/sqlite_db_file.lock'

