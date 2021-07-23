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

# create service init file (sourced by %%service)
init_file=${HOME}/.init_esp-idf.sh
if [ ! -f $init_file ]; then
    echo 'echo setting up IDF ...' > $init_file
    echo '. $IDF_PATH/export.sh > /dev/null' >> $init_file
fi

echo "sleep forever"
sleep_forever
