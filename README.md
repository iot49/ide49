# Collection of Docker Services

## BUILD

Run 

```bash
./build.py <app> [--tag <tag>]
```

to create `docker-compose.yml` for <app>.

## ARCH

* config: .env, .secrets
* nginx: reverse proxy
* mdns-publisher

## BUGS

* hostname differs between network_mode host and bridge ???
* causes issues with sudo

## TODO

- balenaos on mac
- service/jupyter
    * compose: set JUPYTER_IP dynamically
- .nginx
    * move code generation from config -> nginx
    * Note: nginx still needs DOMAIN
- index.html
    * generate dynamically (addresses!)
    * flask?
    * nginx/python?