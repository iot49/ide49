# mdns-publisher

Advertises mdns broadcast domains using the Avahi server of the BalenaOS host.

The domain defaults to `hostname` and can be overriden with environment variable `MDNS_DOMAIN`.

Configuration example:

```yaml
image: ttmetro/mdns-publisher
restart: unless-stopped
labels:
    io.balena.features.dbus: 1
environment:
    - DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
    - MDNS_DOMAIN=my_host
    - MDNS_SUBDOMAINS=jupyter, balena-cli, codeserver
```

This will broadcast the following domains, all pointing to the same IP of the device:

```
my_host.local
jupyter.my_host.local
balena-cli.my_host.local
codeserver.my_host.local
```
