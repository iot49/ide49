#! /bin/bash

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
    cp -r /usr/local/src/nginx /etc
    cp /etc/nginx/htpasswd /etc/nginx/htpasswd.default
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default
    echo 'nginx config v1 installed' >/etc/nginx/.config_v1
fi

# default landing page
if [[ ! -f /home/iot/.html/index.html ]]; then
    mkdir -p /home/iot/.html
    cp /usr/local/src/nginx/html/index.html /home/iot/.html
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

# set name for dns advertising (default iot49.local) & create certificate
if [[ $HOST_NAME != $DNS_NAME || ! -f /etc/nginx/ssl/cert.crt ]]; then
    curl -X PATCH --header "Content-Type:application/json" \
        --data '{"network": {"hostname": "'"$DNS_NAME"'" } }' \
        "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"
    cd /etc/nginx/ssl
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout cert.key -out cert.crt -config cert.conf       
    openssl pkcs12 -export -out cert.pfx -inkey cert.key -in cert.crt -passout pass:
    cp cert.crt /home/iot/.html
fi

# start the server
nginx -g "daemon off;"
