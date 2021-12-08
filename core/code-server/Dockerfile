FROM linuxserver/code-server

RUN echo 'abc ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo

COPY ./start.sh /usr/local/bin/start.sh

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]
