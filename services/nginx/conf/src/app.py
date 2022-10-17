#!/usr/bin/env python
import os
import json

domain = os.getenv('MDNS_DOMAIN')
http_ports = json.loads(os.getenv('HTTP_PORTS'))
host_ip = os.getenv('HOST_IP')

with open('/etc/nginx/proxy.conf', 'w') as file:
    file.write(f"# Machine generated in start.sh (app.py)")
    for service, v in http_ports.items():
        port, host_mode = v
        file.write("""
server {{
    server_name                 {server_name};
    listen                      443 ssl;
    ssl_certificate             /etc/nginx/ssl/cert.crt;
    ssl_certificate_key         /etc/nginx/ssl/cert.key;

    resolver                    127.0.0.11;       

    location / {{
        proxy_pass              http://{url}:{port};
        proxy_redirect          off;
        proxy_set_header        Host $host;

        # websocket support
        proxy_http_version      1.1;
        proxy_set_header        Upgrade "websocket";
        proxy_set_header        Connection "Upgrade";
    }}
}}
""".format(
    server_name=f"{service}.{domain}.local",
    url=host_ip if host_mode else service,
    port=port
))
