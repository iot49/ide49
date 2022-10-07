FROM jupyter/base-notebook

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    # cifs (samba) mount
    cifs-utils \
    fdisk \
    # c runtime library (required by add_hostname)
    musl \
    # ssh into container
    openssh-client \
    git \
    # presently broken - see workaround below
    # github-cli \
    # copied from balena base dockerfile
    curl \
    dirmngr \
    gnupg \
    inetutils-ping \
    iproute2 \
    netbase \
    udev \
    # setuidgid
    daemontools \
    # often useful
    nano \
    apache2-utils \
    bluez \
    build-essential \
    dbus \
    exfat-fuse \
    exfatprogs \
    jq \
    mosquitto-clients \
    picocom \
    subversion \
    usbutils \
    zip \
    # arm32 build tools
    libffi-dev pkg-config libnewlib-arm-none-eabi gcc-arm-none-eabi \
    python3-usb \
    dfu-util \
    # esp32 idf requirements
    apt-utils \
    bison \
    ccache \
    check \
    flex \
    gperf \
    lcov \
    libusb-1.0-0-dev \
    ninja-build \
    libpython2.7 \
    # used by rust (speeds up linking)
    lld \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# RUN pip install mdns-publisher

# rename user jovyan -> "${IOT_USER}"
# do not change group ${NB_UID}:${NB_GID}

# can't redefine value of ARG NB_USER defined in base container
ARG IOT_USER="iot"

ENV NB_USER="${IOT_USER}"
ENV HOME="/home/${IOT_USER}"

RUN usermod --home "/home/${IOT_USER}" --login "${IOT_USER}" -a -G users,dialout jovyan \
 && mkdir "/home/${IOT_USER}" \
 # in case volume mount is not used
 && chown "${NB_UID}:${NB_GID}" "/home/${IOT_USER}" \
 && fix-permissions "${HOME}" \
 && echo "${IOT_USER} ALL=(ALL) NOPASSWD:ALL" | EDITOR="tee -a" visudo \
 && echo 'iot ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo

COPY start.sh /usr/local/bin/

WORKDIR ${HOME}
CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

# switch to user "${IOT_USER}" to avoid running container accidentally as root
# USER ${NB_UID}
