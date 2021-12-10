FROM ttmetro/ide49-scipy-notebook

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
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
COPY env49rc.default /usr/local/src/

# gpio permissions
RUN groupadd gpio \
 && usermod -a -G gpio iot

USER ${NB_UID}

# Install Python 3 packages
RUN mamba install --quiet --yes \
    cmake \
    dbus-python \
    jupyter_bokeh \
    jupyterlab-spellchecker \
    paho-mqtt \
    pynacl \
    pytest \
    pytest-ordering \
    pyusb \
    rsync \
    twine \
 && mamba clean --quiet --all -f -y

# These are not on conda
RUN pip install --default-timeout=1000 \
    RPi.Gpio \
    bleak \
    esptool \
    ghp-import \
    gpiozero \
    # not available on conda for linux64
    jupyter-book \
    nest_asyncio \
    rshell

# iot_kernel (micropython)
RUN echo "force rebuild 2021-12-09" \
 && pip install iot-kernel \
 && python -m iot_kernel.install \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"
