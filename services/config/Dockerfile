FROM alpine:3.16

RUN apk update \
 && apk add --no-cache \
    bash \
    curl \
    jq \
    rsync \
    openssh

COPY conf /usr/local

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

