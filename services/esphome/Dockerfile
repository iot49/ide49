# https://github.com/esphome/esphome/blob/dev/docker/Dockerfile

# FROM homeassistant/home-assistant:stable
FROM esphome/esphome

COPY conf /usr/local/bin
RUN chmod a+x /usr/local/bin/custom-entrypoint.sh

# custom entrypoint that sets up udev automount
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]

CMD ["dashboard", "/config"]
