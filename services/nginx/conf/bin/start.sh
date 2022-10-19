#! /bin/bash

config_dir=/usr/local/src/nginx
www_dir=/service-config/www

# load environment
env_file=/service-config/config/.env
set -a; [[ -f ${env_file} ]] && source ${env_file}; set +a

# conditionally update default configuration
# Note: updates existing ONLY if /usr/local/nginx/ is newer
rsync --update -a /usr/local/nginx/ /etc/nginx/
rsync -a /usr/local/nginx/ /etc/nginx/
chown -R :100 /etc/nginx

mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl

# create new certificate, if needed
if ! grep -q "DNS.1 = ${MDNS_DOMAIN}.local" "cert.conf"; then

echo "creating certificate for *.${MDNS_DOMAIN}.local"

# configuration for self-signed certificate
cat << EOF >cert.conf
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
EOF
 
# set name for dns advertising & create certificate
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout cert.key -out cert.crt -config cert.conf       
openssl pkcs12 -export -out cert.pfx -inkey cert.key -in cert.crt -passout pass:
cp cert.crt ${www_dir}

fi

# conditionally install default web content
# Note: does not overwrite existing files (delete file and restart service to update)
if [[ ! -f /service-config/www/index.html ]]; then
    rsync --ignore-existing -a /usr/local/www/ /service-config/www
    rsync -a /usr/local/www/ /service-config/www
    chown -R 1000:100 /service-config/www
fi

# DEVELOPING & DEBUGGING ...................
rsync -a /usr/local/www/ /service-config/www
chown -R 1000:100 /service-config/www

# /etc/nginx/proxy.conf
/usr/bin/python3 /usr/local/src/app.py

cat /etc/nginx/proxy.conf

# start the server
nginx -g "daemon off;"


