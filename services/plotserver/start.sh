#!/bin/bash

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# add .bashrc
if [[ ( ! -f ~/.bashrc ) && ( -f ~/iot-balena/.bashrc ) ]]; then
    cp ~/iot-balena/.bashrc ~
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

mkdir -p ~/iot49/plotserver/apps

if [ ! -d ~/iot49/plotserver/lib ] ; then
    cp -r /usr/local/src/lib ~/iot49/plotserver
fi

cd ~/iot49/plotserver/lib
python -m plotserver