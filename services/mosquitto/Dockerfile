FROM eclipse-mosquitto

COPY ./mosquitto.conf /usr/local/src/
COPY ./start.sh /usr/local/bin/

CMD [ "/bin/ash", "/usr/local/bin/start.sh" ]
