FROM nginx:stable-alpine

RUN apk update \
 && apk add --no-cache \
    apache2-utils \
    bash \
    iproute2 \
    jq \
    nano \
    openssl \
    python3 \
    rsync

COPY conf /usr/local/

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]


