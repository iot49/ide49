# umqtt.simple not working with versions > 2.0.11
# https://github.com/micropython/micropython-lib/issues/445
FROM eclipse-mosquitto:2.0.11

RUN apk --no-cache add \
    bash \
    openssl

COPY ./mosquitto.conf /usr/local/src/
COPY ./start.sh /usr/local/bin/

CMD [ "/bin/ash", "/usr/local/bin/start.sh" ]

