#!/bin/bash

sleep_forever () {
    while true ; do
        # echo "idling ..."
        sleep 600
    done
}


# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    sudo bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# conditionally mount iot
if [ ${SAMBA:=off} == client ]; then
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

echo "sleep forever"
sleep_forever
