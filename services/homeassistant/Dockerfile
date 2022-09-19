# FROM homeassistant/home-assistant:stable
FROM homeassistant/home-assistant:2022.9.2

RUN apk add \
    github-cli \
    gpsd \
    nano \
    rsync

# Don't run as root & set user "iot" to "inherit" bluetooth access from jupyter service
# https://community.home-assistant.io/t/improving-docker-security-non-root-configuration/399971

COPY run /etc/services.d/home-assistant/run

RUN chmod a+x /etc/services.d/home-assistant/run
