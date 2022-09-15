#!/bin/bash

function setup_user {
    # TODO: check if user exists already to get rid of log message
    #    useradd: user 'iot' already exists
    SMB_USER=${SAMBA_USERNAME:=iot}
    SMB_PASS=${SAMBA_PASSWORD:=iot49}
    useradd --no-create-home -g users -u 1000 $SMB_USER
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
        sleep infinity
    fi
}

# load environment
env_file=/service-config/iot-home/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

main $@
