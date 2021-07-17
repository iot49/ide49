#!/bin/bash

sleep_forever () {
    while true ; do
        # echo "idling ..."
        sleep 600
    done
}

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
