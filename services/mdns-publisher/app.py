#!/usr/bin/env python
import os

args = ['mdns-publish-cname']

with open('/home/pi/.mdns-aliases', 'r') as f:
    for line in f.readlines():
      line = line.strip()
      if line:
        args.append(line.strip())

os.execv('/home/pi/.local/bin/mdns-publish-cname', args)