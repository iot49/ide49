#!/usr/bin/env python
import os

domain = os.getenv('MDNS_DOMAIN') or os.uname()[1]
subdomains = os.getenv('MDNS_SUBDOMAINS').split(',')

mdns_names = [ "mdns-publish-cname", f"{domain}.local" ]
mdns_names.extend([ f"{s.strip()}.{domain}.local" for s in subdomains ])

print("mdns_names", mdns_names)

os.execv('/usr/local/bin/mdns-publish-cname', mdns_names) 