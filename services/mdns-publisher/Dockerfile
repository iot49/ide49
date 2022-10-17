FROM python:3.10-slim-bullseye as builder

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    build-essential \
    dbus \
    libdbus-glib-1-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --default-timeout=1000 \
    dbus-python \
    mdns-publisher

FROM python:3.10-slim-bullseye

COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    dbus \
    libdbus-glib-1-dev \
    curl \
    jq \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf /etc/local

CMD [ "/bin/bash", "/etc/local/bin/start.sh" ]

# CMD [ "mdns-publish-cname", "a.local", "a.b.local", "m.n.local" ]