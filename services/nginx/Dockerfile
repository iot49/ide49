FROM nginx:stable-alpine

RUN apk update && apk add --no-cache bash nano apache2-utils

COPY ./conf /usr/local/src/nginx/
COPY ./start.sh /usr/local/bin/start.sh

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]
