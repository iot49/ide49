FROM python:3.10-slim-bullseye

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    iputils-ping \
    iproute2 \
    rsync \
    ssh \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf /usr/local

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]