FROM python:3.10-slim-bullseye

# TODO: multi-stage build to reduce image size

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    build-essential \
    dbus \
    libdbus-glib-1-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --default-timeout=1000 \
    dbus-python \
    mdns-publisher

COPY app.py /

CMD [ "python", "/app.py" ]

# CMD [ "mdns-publish-cname", "a.local", "a.b.local", "m.n.local" ]