#! /bin/bash

# conditionally mount /home/iot
if [ ${SAMBA:=off} = client ]; then
    # keep trying
    while true
    do
        sudo mount -t cifs //${SAMBA_SERVER_IP:0.0.0.0}/iot-data ${HOME} \
            -ouid=1000,gid=100,username=${SAMBA_USERNAME:=iot},password="${SAMBA_PASSWORD:=iot49}",sec=ntlmssp,domain=WORKGROUP \
        && break
        echo "samba mount failed, keep trying ..."
        sleep 10
    done
    # safe writing to cifs mounted partitions
    export JUPYTER_ALLOW_INSECURE_WRITES=true
    # go to the new home
    cd $HOME
fi
