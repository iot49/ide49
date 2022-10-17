#!/usr/bin/env python
import os

domain = os.getenv('MDNS_DOMAIN')
subdomains = os.getenv('MDNS_SUBDOMAINS')

mdns_names = [ "mdns-publish-cname", f"{domain}.local" ]
if len(subdomains) > 0:
    mdns_names.extend([ f"{s.strip()}.{domain}.local" for s in subdomains.split(',') ])

# print("-"*20, "mdns_names:", mdns_names)

os.execv('/usr/local/bin/mdns-publish-cname', mdns_names)

