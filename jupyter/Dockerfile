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
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# rename user jovyan -> "${NB_USER}"

ENV NB_USER="iot"
ENV HOME="/home/${NB_USER}"

RUN usermod --home "/home/${NB_USER}" --login "${NB_USER}" -a -G users,dialout jovyan \
 && mkdir "/home/${NB_USER}" \
 && chown ${NB_UID}:${NB_GID} "/home/${NB_USER}" \
 && echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" | EDITOR="tee -a" visudo \
 && echo 'iot ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo

COPY conf /usr/local

WORKDIR ${HOME}
CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

# disable for now (ip depends on network_mode)
HEALTHCHECK NONE