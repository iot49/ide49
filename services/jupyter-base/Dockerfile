FROM ttmetro/base-notebook

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    apache2-utils \
    bluez \
    jq \
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
    # ??? version incompatibility with jupyter-book
    # jupyter-bokeh
    jupyterlab-spellchecker \
 && mamba clean --quiet --all -f -y

# PyPi installs (not all are available on Conda)
RUN pip install --default-timeout=1000 \
    asyncio-mqtt \
    bleak
    # jupyter-book
    

# start.sh runs as root!
USER root 
