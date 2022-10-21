FROM ttmetro/base-notebook

ENV UDEV=on

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    bluez \
    unzip \
    dbus libdbus-glib-1-dev libdbus-1-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY start-hook.sh /usr/local/bin
