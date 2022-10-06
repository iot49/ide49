FROM nginx:stable-alpine

RUN apk update \
 && apk add --no-cache \
    apache2-utils \
    bash \
    iproute2 \
    jq \
    nano \
    openssl \
    rsync

COPY ./conf /usr/local/src/nginx/conf
COPY ./www /usr/local/src/nginx/www
COPY ./start.sh /usr/local/bin/start.sh

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]
 
 
 
 
 
 
 
 
