#! /bin/bash

# install default configuration
if [[ ! -f /etc/nginx/.config_v1 ]]; then
    cp -r /usr/local/src/nginx /etc
    cp /etc/nginx/htpasswd /etc/nginx/htpasswd.default
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default
    echo 'nginx config v1 installed' >/etc/nginx/.config_v1
fi

# default landing page
if [[ ! -f /home/iot/.html/index.html ]]; then
    cp /usr/local/src/nginx/html/index.html /home/iot/.html
fi

# start the server
nginx -g "daemon off;"
