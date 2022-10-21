FROM ttmetro/scipy-notebook

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
    bluez \
    build-essential \
    exfat-fuse \
    exfatprogs \
    jq \
    mosquitto-clients \
    picocom \
    subversion \
    usbutils \
    # used by rust (speeds up linking)
    lld \
    # dbus
    dbus libdbus-glib-1-dev libdbus-1-dev \
    # arm32 build tools
    libffi-dev pkg-config libnewlib-arm-none-eabi gcc-arm-none-eabi \
    python3-usb \
    dfu-util \
    # esp32 idf requirements
    apt-utils \
    bison \
    ccache \
    check \
    flex \
    gperf \
    lcov \
    libusb-1.0-0-dev \
    ninja-build \
    libpython2.7 \
    zip \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# gpio without root
COPY udev-rules /etc/udev/rules.d/

# bluetooth & gpio permissions
RUN chmod a+x /usr/local/bin/*sh \
 && groupadd gpio \
 && usermod -a -G gpio,bluetooth iot

USER ${NB_UID}

# Install Python 3 packages
RUN mamba install --quiet --yes \
    cmake \
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

# PyPi installs (not all are available on Conda)
RUN pip install --default-timeout=1000 \
    asyncio-mqtt \
    bleak \
    dbus-python \
    ghp-import \
    gpiozero \
    gpxpy \
    hass_pyscript_kernel \
    iot-kernel \
    # requires outdated libraries
    # jupyter-book
    joulescope \
    nest_asyncio \
    RPi.Gpio \
    rshell \
    pyserial-asyncio
    
RUN python -m iot_kernel.install \
 && jupyter pyscript install \
 && fix-permissions "${CONDA_DIR}"

# start.sh runs as root!
USER root 
