FROM nginx:stable

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
    bash \
    iproute2 \
    jq \
    nano \
    openssl \
    python3 \
    rsync \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

