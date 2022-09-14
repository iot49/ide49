FROM linuxserver/code-server

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    python3 \
    rsync \
 && echo 'abc ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo

COPY ./start.sh /usr/local/bin/start.sh

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]
