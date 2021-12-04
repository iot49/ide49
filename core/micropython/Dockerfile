FROM ttmetro/ide49-scipy-notebook

USER root

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
    bluetooth \
    bluez \
    build-essential \
    dbus \
    exfat-fuse \
    exfat-utils \
    jq \
    libbluetooth-dev \
    mosquitto-clients \
    picocom \
    python3-dbus \
    python3-usb \
    subversion \
    usbutils \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# copy startup configuration
COPY conf /usr/local/bin/
RUN chmod a+x /usr/local/bin/*.sh

USER ${NB_UID}

# Install Python 3 packages
RUN mamba install --quiet --yes \
    jupyterlab-spellchecker \
    paho-mqtt \
    pynacl \
    pytest \
    pytest-ordering \
    pyusb \
 && mamba clean --quiet --all -f -y \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

RUN pip install --default-timeout=1000 \
    RPi.Gpio \
    bleak \
    esptool \
    gpiozero \
    rshell
#     jupyter-bokeh \

# iot_kernel (micropython)
RUN echo "force rebuild 2021-12-03:17" \
 && pip install iot-kernel \
 && python -m iot_kernel.install \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

# && pip install iot-device>=0.5.21 \
# && pip install iot-kernel>=0.5.26 \

