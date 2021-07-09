FROM linuxserver/duplicati:latest

ENV DEBIAN_FRONTEND=noninteractive

# Enable udev for detection of dynamically plugged devices
ENV UDEV=on
COPY udev/usb.rules /etc/udev/rules.d/usb.rules

# Install dependencies (install_packages not available)
# lsof?
RUN apt-get update && apt-get install -y \
  udev \
  exfat-fuse exfat-utils \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src
COPY scripts scripts
RUN chmod +x scripts/*

CMD [ "/bin/bash", "/usr/src/scripts/start.sh" ]
