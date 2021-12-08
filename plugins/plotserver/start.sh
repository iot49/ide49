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

# add .bashrc
if [[ ( ! -f ~/.bashrc ) && ( -f ~/service-config/iot-home/.bashrc ) ]]; then
    cp ~/service-config/iot-home/.bashrc ~
fi

# conditionally mount /home/iot
if [ ${SAMBA:=off} == client ]; then
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
fi

# in case it's not defined as application variable ...
export IOT_PROJECTS="${IOT_PROJECTS:=/home/iot/projects}"

mkdir -p ${IOT_PROJECTS}/plotserver/apps

if [ ! -d $IOT_PROJECTS/plotserver/lib ] ; then
    cp -r /usr/local/src/lib $IOT_PROJECTS/plotserver
fi

sleep infinity

cd $IOT_PROJECTS/plotserver/lib
python -m plotserver
