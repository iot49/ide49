FROM ttmetro/base-notebook

# bluetooth: https://github.com/balenablocks/bluetooth
# special entry.sh! resets interface?
# but it's a pairing agent ... not all may be required

ENV UDEV=on

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes \
 && apt-get install --yes --no-install-recommends \
    bluez \ 
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && pip install \
    jupyter-book

COPY start-hook.sh /usr/local/bin
