#!/bin/bash

function setup_user {
    # TODO: check if user exists already to get rid of log message
    #    useradd: user 'iot' already exists
    SMB_USER=${SAMBA_SERVER_USERNAME:=iot}
    SMB_PASS=${SAMBA_SERVER_PASSWORD:=iot49}
    useradd --no-create-home -g users -u 1000 $SMB_USER
    usermod -aG sambashare $SMB_USER
    printf "%s\n%s\n" ${SMB_PASS} ${SMB_PASS} | smbpasswd -a -s $SMB_USER
    smbpasswd -e $SMB_USER
}

function main {
    if [ ! -z "$SAMBA_SERVER_PASSWORD" ]
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
env_file=/service-config/config/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

main $@
