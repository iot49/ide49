#! /bin/bash

# conditionally mount /home/iot
if [ ${SAMBA:=off} = client ]; then
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
    # go to the new home
    cd $HOME
fi
