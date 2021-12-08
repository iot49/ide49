#!/bin/bash

function sleep_forever {
    while : ; do
        # echo "idling ..."
        sleep 600
    done
}

function setup_user {
    # TODO: check if user exists already to get rid of log message
    #    useradd: user 'iot' already exists
    SMB_USER=${SAMBA_USERNAME:=iot}
    SMB_PASS=${SAMBA_PASSWORD:=iot49}
    useradd --no-create-home -u 1000 $SMB_USER
    usermod -aG sambashare $SMB_USER
    printf "${SMB_PASS}\n${SMB_PASS}\n" | smbpasswd -a -s $SMB_USER
    smbpasswd -e $SMB_USER
}

function main {
    if [ "$SAMBA" == server ]
    then
        echo "Start samba server"
        setup_user
        smbd $@
    else
        echo "Samba server disabled"
        sleep_forever
    fi
}

# customize device environment (e.g. SAMBA_PASSWORD)
env49rc=/service-config/iot-home/.env49rc
if [ -f $env49rc ]; then
    echo sourcing $env49rc ...
    source $env49rc
fi

main $@
