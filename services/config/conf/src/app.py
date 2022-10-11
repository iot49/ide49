#!/usr/bin/env python
import os

domain = os.getenv('MDNS_DOMAIN')
subdomains = os.getenv('SERVICES')
print("SUB 1", type(subdomains), subdomains)

import socket

print("HN", socket.gethostname(), os.uname()[1])
print("T", type(os.environ))
print(dict(os.environ))

print("XXX", os.getenv('XXX'))

domain = os.getenv('XXX') or os.uname()[1]
print("DOM", domain)