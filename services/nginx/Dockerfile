FROM nginx:stable

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
    bash \
    curl \
    iproute2 \
    iputils-ping \
    nano \
    openssl \
    python3 \
    rsync \
    wget \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf /usr/local

CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

