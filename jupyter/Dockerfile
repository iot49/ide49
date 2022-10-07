# BASE: see https://jupyter-docker-stacks.readthedocs.io/ & Dockerhub for selection
# E.g.  jupyter/base-notebook
#       jupyter/scipy-notebook

ARG BASE="jupyter/base-notebook"
FROM ${BASE}

USER root

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    # setuidgid
    daemontools \
    # cifs (samba) mount
    cifs-utils \
    fdisk \
    # ssh into host
    openssh-client \
    git \
    # used in start
    rsync \
    # copied from balena base dockerfile
    curl \
    dirmngr \
    gnupg \
    inetutils-ping \
    iproute2 \
    netbase \
    udev \
    # often useful
    nano \
    # dbus - move to derived container
    libdbus-glib-1-dev libdbus-1-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

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

# COPY start.sh /usr/local/bin/
COPY conf /usr/local

WORKDIR ${HOME}
CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]
