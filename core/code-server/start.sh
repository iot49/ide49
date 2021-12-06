#! /bin/bash

sleep_forever () {
    while : ; do
        # echo "idling ..."
        sleep 600
    done
}

# add .bashrc
if [ ! -f ~/.bashrc ] && [ -f /home/iot/.bashrc ]; then
    cp /home/iot/.bashrc ~
fi

# add hostname to /etc/hosts (makes sudo happy)
if ! grep -q `hostname` /etc/hosts; then
    bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
fi

# conditionally mount /home/iot
if [ ${SAMBA:=off} = client ]; then
    # keep trying
    while true
    do
        sudo mount -t cifs //${SAMBA_SERVER_IP}/iot-data /config/workspace \
            -ouid=1000,gid=100,username=iot,password="${SAMBA_PASSWORD}",sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
fi


# Note: /config/custom-cont-init.d executed (if it exists) when code-server starts

sleep_forever
