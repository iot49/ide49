FROM ttmetro/ide49-base-notebook

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}
