#!/usr/bin/env python
import os

domain = os.getenv('MDNS_DOMAIN')
subdomains = os.getenv('MDNS_SUBDOMAINS').split(',')

mdns_names = [ "mdns-publish-cname", f"{domain}.local" ]
mdns_names.extend([ f"{s.strip()}.{domain}.local" for s in subdomains ])

os.execv('/usr/local/bin/mdns-publish-cname', mdns_names) 