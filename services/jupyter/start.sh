#!/bin/bash

# running as root! (see Dockerfile)

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    echo adding hostname `hostname`
    bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# set permissions for gpio as non-root user (gpio group)
chown root.gpio /dev/gpiomem
chmod g+rw /dev/gpiomem
chown root.gpio /sys/class/gpio/*export
chmod ug+rwx /sys/class/gpio/*export

# switch to user iot
sudo \
    --preserve-env=BALENA \
    --preserve-env=BALENA_APP_ID \
    --preserve-env=BALENA_APP_NAME \
    --preserve-env=BALENA_DEVICE_ARCH \
    --preserve-env=BALENA_DEVICE_NAME_AT_INIT \
    --preserve-env=BALENA_DEVICE_TYPE \
    --preserve-env=BALENA_DEVICE_UUID \
    --preserve-env=BALENA_HOST_OS_VERSION \
    --preserve-env=BALENA_SERVICE_HANDOVER_COMPLETE_PATH \
    --preserve-env=BALENA_SERVICE_NAME \
    --preserve-env=BALENA_SUPERVISOR_ADDRESS \
    --preserve-env=BALENA_SUPERVISOR_API_KEY \
    --preserve-env=BALENA_SUPERVISOR_HOST \
    --preserve-env=BALENA_SUPERVISOR_PORT \
    --preserve-env=PYTHON_DBUS_VERSION \
    --preserve-env=PYTHON_VERSION \
    --preserve-env=DNS_NAME \
    -i -u iot /bin/bash << EOF

# conditionally mount /home/iot
if [[ ${SAMBA:=off} == client ]]; then
    sudo mkdir -p /home/iot
    echo mount //${SAMBA_SERVER_IP}/iot-data on /home/iot
    while true
    do
        sudo mount -t cifs //${SAMBA_SERVER_IP}/iot-data /home/iot \
            -ouid=1000,gid=1000,username=iot,password=${SAMBA_PASSWORD},sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
fi

# go to new home (/home/iot)
cd

export IOT="${IOT:=~}"
export IOT49="${IOT49:=~/iot49}"

# user initializations
# for some reason using a variable here does not work ???
# user_start=~/bin/start-${BALENA_SERVICE_NAME:=jupyter}.sh
if [ -f ~/bin/start-$BALENA_SERVICE_NAME.sh ]; then
    echo source ~/bin/start-$BALENA_SERVICE_NAME.sh ...
    source ~/bin/start-$BALENA_SERVICE_NAME.sh
fi

# add .bashrc
if [[ ( ! -f ~/.bashrc ) && ( -f ~/iot-balena/.bashrc ) ]]; then
    cp ~/iot-balena/.bashrc ~
fi

# add .gitignore_global
if [[ ( ! -f ~/.gitignore_global ) && ( -f ~/iot-balena/.gitignore_global ) ]]; then
    cp ~/iot-balena/.gitignore_global ~
    git config --global core.excludesfile=~/.gitignore_global
fi

# Start jupyter ...

# store custom lab extensions in user writable folder
# https://jupyterlab.readthedocs.io/en/latest/user/directories.html
# export JUPYTERLAB_DIR=/home/iot/.jupyter

# fix runtime file permissions issue
# https://github.com/jupyter/notebook/issues/5058
export JUPYTER_RUNTIME_DIR="${JUPYTER_RUNTIME_DIR:=/service-config/iot-home/.local/share/jupyter/runtime}"

# never save config (especially sqlite history lock) to samba share
# history lock ERROR: https://gitter.im/ipython/ipython/help/archives/2017/04/20
mkdir -p /service-config/iot-home/.ipython
export IPYTHONDIR="${IPYTHONDIR:=/service-config/iot-home/.ipython}"

# never save sqlite lock on samba share!
jupyter lab --ip='172.17.0.1' --port=8888 --no-browser \
    --ServerApp.base_url='/jupyter' \
    --ServerApp.token='' --ServerApp.password='' \
    --NotebookNotary.db_file='/service-config/iot-home/.ipython/sqlite_db_file.lock'

EOF
