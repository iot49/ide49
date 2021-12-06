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
            -ouid=1000,gid=100,username=iot,password="${SAMBA_PASSWORD}",sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
    # safe writing to cifs mounted partitions
    export JUPYTER_ALLOW_INSECURE_WRITES=true
fi

# Start jupyter ...

# Configure & start Jupyter server
# Store configuration locally (not on cifs mount) and in per service directory
jconfig=/service-config/iot-home/.config-jupyter/$BALENA_SERVICE_NAME
mkdir -p ${jconfig}

# store custom lab extensions in user writable folder
# https://jupyterlab.readthedocs.io/en/latest/user/directories.html
export JUPYTERLAB_DIR="${JUPYTERLAB_DIR:=${jconfig}/.jupyter}"

# fix runtime file permissions issue
# https://github.com/jupyter/notebook/issues/5058
export JUPYTER_RUNTIME_DIR="${JUPYTER_RUNTIME_DIR:=${jconfig}/runtime}"

# never save config (especially sqlite history lock) to samba share
# history lock ERROR: https://gitter.im/ipython/ipython/help/archives/2017/04/20
mkdir -p ${jconfig}/.ipython
export IPYTHONDIR="${IPYTHONDIR:=${jconfig}/.ipython}"

if [ ! -d ${JUPYTERLAB_DIR} ]; then
    echo "Building jupyter lab assets, this may take some time ..."
    jupyter lab build
    # jupyter lab build --dev-build=False --minimize=False
fi

# start the jupyter server behind nginx proxy
jupyter lab --no-browser \
    --ip="${JUPYTER_IP:='*'}" \
    --port="${JUPYTER_PORT:=8891}" \
    --ServerApp.base_url="/${BALENA_SERVICE_NAME}" \
    --ServerApp.token="" --ServerApp.password="" \
    --NotebookNotary.db_file="${jconfig}/.ipython/sqlite_db_file.lock"
