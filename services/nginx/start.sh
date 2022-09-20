#! /bin/bash

config_dir=/usr/local/src/nginx
www_dir=/service-config/www

# load environment (DNS_NAME, ...)
env_file=/service-config/iot-home/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

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

# conditionally update default configuration
# Note: updates existing (nginx.template.conf) ONLY if ${config_dir}/conf/ is newer
# E.g. edits of ${config_dir}/conf/nginx.template.conf will persist until a new version
#      of the service is pushed with a newer ${config_dir}/conf/nginx.template.conf
rsync --update -a ${config_dir}/conf/ /etc/nginx/

# set correct host IP in nginx.conf (i.e. nginx.conf is overwitten in each container start)
# Note: do this each time in case HOST_IP changes (I have no clue how it is set)
host_ip=`ip route | awk '{print $3}' | head -n 1`
sed "s/HOST_IP/$host_ip/g" /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf
echo ${host_ip} > /etc/nginx/host_ip

# conditionally install default web content
# Note: does not overwrite existing files (delete file and restart service to update)
if [[ ! -f ${www_dir}/index.html ]]; then
    rsync --ignore-existing -a ${config_dir}/www/. ${www_dir}
    chown -R 1000:100 ${www_dir}
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
OU = iot49-${DNS_NAME}
CN = iot49-${DNS_NAME}
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
    cp cert.crt ${www_dir}
fi

# start the server
nginx -g "daemon off;"
