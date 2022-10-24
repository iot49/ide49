# TODO

## segment bridge network

* e.g. LibreOffice, Grafana, Wireshark all on port 3000!

## fix syncthing conflicts

* whenever file is added on linux
* no problem when file is added on mac

## drop Internet from start.sh (config)

* no api connection
* ignore hostname

## balena-cli

* balena-engine via ssh script
* ssh -p 22222 root@$HOST_IP -- balena-engine

https://github.com/balena-io/balena-cli/blob/master/INSTALL-LINUX.md

```bash
curl -L --output x.zip https://github.com/balena-io/balena-cli/releases/download/v14.5.0/balena-cli-v14.5.0-linux-x64-standalone.zip
```

# mosquitto

* update cert if MDNS_DOMAIN changed
* get rid of .config_v1 (just do not overwrite conf)