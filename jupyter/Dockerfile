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
    # utility
    curl \
    dirmngr \
    dnsutils \
    gnupg \
    inetutils-ping \
    iproute2 \
    nano \
    netbase \
    rsync \
    udev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# rename user jovyan -> "${NB_USER}"

ENV NB_USER="iot"
ENV HOME="/home/${NB_USER}"

# HOME will be shadowed by mount, but a folder is required during the build (e.g. mamba cache)
RUN usermod -l ${NB_USER} -G users,dialout jovyan \
 && usermod -d ${HOME} -m ${NB_USER} \
 && echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" | EDITOR="tee -a" visudo \
 && echo 'iot ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo

COPY conf /usr/local

WORKDIR ${HOME}
CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

# disable for now (ip depends on network_mode)
HEALTHCHECK NONE