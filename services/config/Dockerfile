FROM python:3.10-slim-bullseye

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    curl \
    iputils-ping \
    iproute2 \
    jq \
    rsync \
    ssh \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf /usr/local

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]
