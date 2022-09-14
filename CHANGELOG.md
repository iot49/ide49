# Change Log

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.0.0rc1] - 2022-09-15

* Modularized build system
    * ./build.sh <app> [--push] [--tag <tag>]: 
        * create custom `./docker-compose.yml`
        * build and push with balena-cli
    * ./apps
    * ./services
* Configuration @ /service-config/config
* Secrets @  /service-config/config/secrets.yaml
 
## [] - 2022-08-29

* Add several containers (home assistant, influxdb, ...)
* Drop esp-idf container
 
## [1.0.1] - 2022-07-10

### Updates

* Update container versions
 
### Fixed

Service **nginx**.

Dynamically set correct host IP address in `etc/nginx/nginx.conf`.

Background: This IP is not fixed and changed e.g. after upgrading the Balena OS. The solution is to generate `nginx.conf` from `nginx.template`, substituting the correct `HOST_IP` with `ip route | awk '{print $3}' | head -n 1` when the container starts (`start.sh`).

## [1.0.0] - 2022-01-07
  
Initial release