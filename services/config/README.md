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
