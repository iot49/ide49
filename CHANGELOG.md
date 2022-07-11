# Change Log

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [1.0.1] - 2022-07-10

### Updates

* Update container versions
 
### Fixed

Service **nginx**.

Dynamically set correct host IP address in `etc/nginx/nginx.conf`.

Background: This IP is not fixed and changed e.g. after upgrading the Balena OS. The solution is to generate `nginx.conf` from `nginx.template`, substituting the correct `HOST_IP` with `ip route | awk '{print $3}' | head -n 1` when the container starts (`start.sh`).

## [1.0.0] - 2022-01-07
  
Initial release