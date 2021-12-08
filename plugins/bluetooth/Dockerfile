FROM ttmetro/ide49-base-notebook

USER root

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    bluez \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# install this as root ...
RUN pip install bleak \
 && usermod -G bluetooth iot
 
# Note: bluetooth requires ROOT!
