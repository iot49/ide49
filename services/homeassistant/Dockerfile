# https://github.com/home-assistant/docker/blob/master/Dockerfile

# FROM homeassistant/home-assistant:stable
FROM homeassistant/home-assistant:2022.8.7

COPY custom_run /etc/services.d/home-assistant/run
COPY balena-entry.sh /usr/local/bin

RUN chmod a+x /etc/services.d/home-assistant/run \
 && apk add \
    gpsd \
    nano \
    rsync

