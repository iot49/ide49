#! /bin/ash

mkdir -p /mosquitto/config
mkdir -p /mosquitto/data
mkdir -p /mosquitto/log
mkdir -p /mosquitto/certs

# customize device environment (MOSQUITTO)
env_file=/service-config/iot-home/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

# install default configuration
if [ ! -f /mosquitto/.config_v1 ]
then
    # create certificates
    IP=$(curl -s -X GET --header "Content-Type:application/json" \
           "$BALENA_SUPERVISOR_ADDRESS/v1/device?apikey=$BALENA_SUPERVISOR_API_KEY" | \
           jq -r ".ip_address")
    CA_PWD="iot49"
    SUBJ="/C=US/ST=CA/L=San Francisco/CN=${IP}"
    cd /mosquitto/certs
    openssl genrsa -des3 -passout pass:${CA_PWD} -out ca.key 2048
    openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -passin pass:${CA_PWD} -subj "${SUBJ}/O=IoT49-CA"
    openssl genrsa -out broker.key 2048
    openssl req -new -out broker.csr -key broker.key -subj "${SUBJ}/O=IoT49"
    openssl x509 -req -in broker.csr -passin pass:${CA_PWD} \
             -CA ca.crt -CAkey ca.key -CAcreateserial -out broker.crt -days 3650
    
    echo IP = ${IP}
    echo SUBJ = ${SUBJ}

    # create acl file
    echo "topic readwrite public/#" >/mosquitto/config/public.acl

    # create password file for default user (iot49) and password (iot49)
    mosquitto_passwd -c -b /mosquitto/config/password_file iot49 iot49

    # install configuration file
    cp /usr/local/src/mosquitto.conf /mosquitto/config

    # do not overwrite user customizations
    echo "mosquitto config v1 installed" >/mosquitto/.config_v1
else
    echo "not updating config v1"
fi

# start the broker
if [ ${MOSQUITTO:=on}  == on ]; then
    /usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf
fi
