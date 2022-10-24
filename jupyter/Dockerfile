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
    unzip \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# install balena-cli
WORKDIR /tmp
RUN curl -L --output balena-cli.zip https://github.com/balena-io/balena-cli/releases/download/v14.5.0/balena-cli-v14.5.0-linux-x64-standalone.zip \
 && unzip -d /usr/local/bin balena-cli.zip \
 && rm balena-cli.zip

# rename user ${NB_USER} -> "${IOT_USER}"
# (Note: cannot change ARG NB_USER)

ENV IOT_USER="iot"
ENV HOME="/home/${IOT_USER}"

# HOME will be shadowed by mount, but a folder is required during the build (e.g. mamba cache)
RUN usermod -l ${IOT_USER} -G users,dialout ${NB_USER} \
 && usermod -d ${HOME} -m ${IOT_USER} \
 && echo "${IOT_USER} ALL=(ALL) NOPASSWD:ALL" | EDITOR="tee -a" visudo \
 && echo 'iot ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo

COPY conf /usr/local

WORKDIR ${HOME}
CMD [ "/bin/bash", "/usr/local/bin/start.sh" ]

# disable for now (ip depends on network_mode)
HEALTHCHECK NONE