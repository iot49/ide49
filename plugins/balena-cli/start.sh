#!/bin/bash

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# customize device environment (e.g. SAMBA_PASSWORD)
env49rc=/service-config/iot-home/.env49rc
if [ -f $env49rc ]; then
    echo sourcing $env49rc ...
    source $env49rc
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

# Jupyter file location issues:
#   1) $HOME may be cifs mounted --> store config on /service-config/iot-home
#   2) We are running multiple servers - does some data need to be kept separate?
#      - place NotebookNotary.db_file in per-service location, not sure it's required
#      - ditto for runtime
# https://jupyter.readthedocs.io/en/latest/use/jupyter-directories.html

jconfig=/service-config/iot-home/.config-jupyter/$BALENA_SERVICE_NAME
mkdir -p ${jconfig}

# don't share config between services (?)
export JUPYTER_CONFIG_DIR=${jconfig}/.jupyter
# export JUPYTER_CONFIG_DIR=/service-config/iot-home/.jupyter

# kernelspec, default: ~/.local/share/jupyter/
export JUPYTER_PATH=${jconfig}/.local

# separate runtime directory for each service
export JUPYTER_RUNTIME_DIR=${jconfig}

# sqlite database
export IPYTHONDIR=${jconfig}/.ipython

jupyter --path
jupyter lab path

# start the jupyter server behind nginx proxy
jupyter lab --no-browser --allow-root \
    --ServerApp.ip=${JUPYTER_IP:='*'} \
    --ServerApp.port=${JUPYTER_PORT:=8888} \
    --ServerApp.base_url=/${BALENA_SERVICE_NAME} \
    --ServerApp.token="" --ServerApp.password="" \
    --NotebookNotary.db_file="${jconfig}/sqlite_db_file.lock"
