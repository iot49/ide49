#!/bin/bash

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# conditionally mount iot
if [ ${SAMBA:=off} = client ]; then
    sudo mkdir -p ${HOME}
    # keep trying
    while true
    do
        sudo mount -t cifs //${SAMBA_SERVER_IP}/iot-data ${HOME} \
            -ouid=1000,gid=1000,username=iot,password="${SAMBA_PASSWORD}",sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
fi

# Start jupyter ...

# fix runtime file permissions issue
# https://github.com/jupyter/notebook/issues/5058
export JUPYTER_RUNTIME_DIR="${JUPYTER_RUNTIME_DIR:=/service-config/iot-home/.local/share/jupyter/runtime}"

# never save config (especially sqlite history lock) to samba share
# history lock ERROR: https://gitter.im/ipython/ipython/help/archives/2017/04/20
mkdir -p /service-config/iot-home/.ipython
export IPYTHONDIR="${IPYTHONDIR:=/service-config/iot-home/.ipython}"

# never save sqlite lock on samba share!
# ip='172.17.0.2' for nginx, but could change
jupyter lab --ip='*' --port=8889 --no-browser \
    --ServerApp.base_url='/balena-cli' \
    --ServerApp.token='' --ServerApp.password='' \
    --NotebookNotary.db_file='/service-config/iot-home/.ipython/sqlite_db_file.lock'
