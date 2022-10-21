# Collection of Docker Services

## BUILD

Run `./build.py` to create `docker-compose.yml` for <app>.

### Usage:

```tex
$ ./build.py -h
usage: build.py [-h] [--tag TAG] [--nocache] [--build] [--debug] app [action]

Assemble docker app from spec file and compose-template and push to balena fleet

positional arguments:
  app          app specification in app/ folder
  action       deploy (default), build or none

optional arguments:
  -h, --help   show this help message and exit
  --tag TAG    optional balena release tag
  --nocache    do not use previously built images when building the app
  --build      force build (deploy)
  --debug, -d  print debugging output
```

### Examples:

Build File: (e.g. app/dev.yml)

```
services:
  - config
  - nginx
  - mdns-publisher
  - http-tester
  - plex

fleets:
  # specify ip address to build in "local mode" (enable in Balena Dashboard)
  # local mode does not send the app to the balena server and is much faster
  # - 192.168.1.92
  - test-amd64
```

1) Build app on machine where `balena` is running:

```bash
./build.sh dev --nocache --build
```

or 

```bash
./build.sh dev deploy --nocache --build
```

2) Build remotely (on balena servers):

```bash
./build.sh dev push 
```
