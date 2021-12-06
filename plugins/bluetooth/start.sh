#!/bin/bash

# we are root!

# add hostname to /etc/hosts (makes sudo happy ... although not needed here!)
if ! grep -q `hostname` /etc/hosts; then
    bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# conditionally mount iot
if [ ${SAMBA:=off} = client ]; then
    mkdir -p ${HOME}
    # keep trying
    while true
    do
        mount -t cifs //${SAMBA_SERVER_IP}/iot-data ${HOME} \
            -ouid=1000,gid=100,username=iot,password="${SAMBA_PASSWORD}",sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
fi

# sleep forever ...
while true; do sleep 10000; done
