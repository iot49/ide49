#! /bin/bash

config_dir=/usr/local/src/nginx
www_dir=/service-config/www

# load environment (DNS_NAME, ...)
env_file=/service-config/config/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

# external IP (ipv4 only)
export IP=$(curl -s -X GET --header "Content-Type:application/json" \
           "$BALENA_SUPERVISOR_ADDRESS/v1/device?apikey=$BALENA_SUPERVISOR_API_KEY" | \
           jq -r ".ip_address" | awk '{print $1}' )

# current HOST_NAME
export HOST_NAME=$(curl -s -X GET --header "Content-Type:application/json" \
           "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY" | \
           jq ".network.hostname")
HOST_NAME="${HOST_NAME%\"}"
HOST_NAME="${HOST_NAME#\"}"

# conditionally update default configuration
# Note: updates existing ONLY if /usr/local/nginx/ is newer
rsync --update -a /usr/local/nginx/ /etc/nginx/
rsync -a /usr/local/nginx/ /etc/nginx/
chown -R :100 /etc/nginx

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
OU = iot49-${MDNS_DOMAIN}
CN = iot49-${MDNS_DOMAIN}
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${MDNS_DOMAIN}.local
DNS.2 = *.${MDNS_DOMAIN}.local
IP.1  = $IP
EOF

# set name for dns advertising & create certificate
if [[ $HOST_NAME != $MDNS_DOMAIN || ! -f /etc/nginx/ssl/cert.crt ]]; then
    echo Updating hostname from $HOST_NAME to $MDNS_DOMAIN
    curl -X PATCH --header "Content-Type:application/json" \
        --data '{"network": {"hostname": "'"$MDNS_DOMAIN"'" } }' \
        "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"
    cd /etc/nginx/ssl
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout cert.key -out cert.crt -config cert.conf       
    openssl pkcs12 -export -out cert.pfx -inkey cert.key -in cert.crt -passout pass:
    cp cert.crt ${www_dir}
fi

# conditionally install default web content
# Note: does not overwrite existing files (delete file and restart service to update)
if [[ ! -f /service-config/www/index.html ]]; then
    rsync --ignore-existing -a /usr/local/www/ /service-config/www
    chown -R 1000:100 /service-config/www
fi

# start the server
nginx -g "daemon off;"
