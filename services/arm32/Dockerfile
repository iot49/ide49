FROM ttmetro/base-notebook

USER root

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    build-essential \
    libffi-dev pkg-config libnewlib-arm-none-eabi gcc-arm-none-eabi \
    python3-usb \
    dfu-util \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
