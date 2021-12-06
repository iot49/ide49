FROM ttmetro/ide49-scipy-notebook

USER root

RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
    bluez \
    build-essential \
    dbus \
    exfat-fuse \
    exfat-utils \
    jq \
    mosquitto-clients \
    picocom \
    subversion \
    usbutils \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# gpio without root
COPY 99-com.rules /etc/udev/rules.d/
COPY start-hook.sh /usr/local/bin/

# bluetooth and gpio permissions
# bluetooth not available without root anyway ...
RUN groupadd gpio \
 && usermod -G bluetooth,gpio iot

USER ${NB_UID}

# Install Python 3 packages
RUN mamba install --quiet --yes \
    dbus-python \
    jupyterlab-spellchecker \
    paho-mqtt \
    pynacl \
    pytest \
    pytest-ordering \
    pyusb \
 && mamba clean --quiet --all -f -y

# These are not on conda
RUN pip install --default-timeout=1000 \
    RPi.Gpio \
    bleak \
    esptool \
    gpiozero \
    rshell
    # jupyter-bokeh

# iot_kernel (micropython)
RUN echo "force rebuild 2021-12-03" \
 && pip install iot-kernel \
 && python -m iot_kernel.install \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"
