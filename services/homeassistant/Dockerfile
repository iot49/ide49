FROM homeassistant/home-assistant:stable

RUN apk add \
    github-cli \
    gpsd \
    nano \
    rsync

# Don't run as root & set user "iot" to "inherit" bluetooth access from jupyter service
# https://community.home-assistant.io/t/improving-docker-security-non-root-configuration/399971

RUN echo CACHE BUSTER

COPY run /etc/services.d/home-assistant/run

RUN chmod a+x /etc/services.d/home-assistant/run
