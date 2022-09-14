## Service `config`

Maintains shared configuration at `/service-config/config`.

**Note:**
Copies default configuration ONLY if `/service-config/config/secrets.yaml` does not exist.

**TODO:** use `rsync` instead?

### Features

#### `secrets.yaml`

Root source for all secrets. Used for configuration (by other containers). Homeassistant gets the secrets from this file.

#### `bin/balena_entry.sh`

Enable dynamic mounting of USB devices. Handled automatically in balena containers, controlled by UDEV environment variable.

Also requires

```yaml
labels:
    io.balena.features.dbus: 1
```

in `compose.yml`.

#### `bin/add_hostname`

Adds the hostname to /etc/hosts without needing sudo to enable sudo without root.

Solves a chicken-and-egg issue in containers (e.g. jupyter stack) that lack this entry.

Does the same as

```bash
bash -c 'echo "127.0.0.1" `hostname` >> /etc/hosts'
```

but without sudo.