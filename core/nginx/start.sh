#! /bin/bash

# customize device environment (e.g. DNS_NAME)
env49rc=/service-config/iot-home/.env49rc
if [ -f $env49rc ]; then
    echo sourcing $env49rc ...
    source $env49rc
fi

# set default dns: iot49.local
export DNS_NAME=${DNS_NAME:=iot49}

export IP=$(curl -s -X GET --header "Content-Type:application/json" \
           "$BALENA_SUPERVISOR_ADDRESS/v1/device?apikey=$BALENA_SUPERVISOR_API_KEY" | \
           jq -r ".ip_address")

export HOST_NAME=$(curl -s -X GET --header "Content-Type:application/json" \
           "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY" | \
           jq ".network.hostname")
HOST_NAME="${HOST_NAME%\"}"
HOST_NAME="${HOST_NAME#\"}"

# install default configuration
if [[ ! -f /etc/nginx/.config_v1 ]]; then
    cp -r /usr/local/src/nginx/* /etc/nginx/
    chown -R 1000:100 /etc/nginx/html
    cp /etc/nginx/htpasswd /etc/nginx/htpasswd.default
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default
    echo 'nginx config v1 installed' >/etc/nginx/.config_v1
fi

# configuration for self-signed certificate
mkdir -p /etc/nginx/ssl
cat << EOF >/etc/nginx/ssl/cert.conf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = CA
L = San Francisco
O = Electronics for IoT
OU = iot49
CN = iot49
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${DNS_NAME}.local
DNS.2 = $IP
IP.1  = $IP
EOF

# set name for dns advertising & create certificate
if [[ $HOST_NAME != $DNS_NAME || ! -f /etc/nginx/ssl/cert.crt ]]; then
    curl -X PATCH --header "Content-Type:application/json" \
        --data '{"network": {"hostname": "'"$DNS_NAME"'" } }' \
        "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"
    cd /etc/nginx/ssl
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout cert.key -out cert.crt -config cert.conf       
    openssl pkcs12 -export -out cert.pfx -inkey cert.key -in cert.crt -passout pass:
    cp cert.crt /etc/nginx/html
fi

# start the server
nginx -g "daemon off;"
