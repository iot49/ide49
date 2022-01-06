FROM eclipse-mosquitto

RUN apk --no-cache add \
    bash \
    curl \
    jq \
    openssl

COPY ./mosquitto.conf /usr/local/src/
COPY ./start.sh /usr/local/bin/

CMD [ "/bin/ash", "/usr/local/bin/start.sh" ]
