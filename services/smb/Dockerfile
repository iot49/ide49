# https://github.com/balena-io-playground/balena-samba
# FROM balenalib/%%BALENA_ARCH%%-ubuntu:focal-run

FROM ubuntu:focal

ENV UDEV=1
EXPOSE 139 445

RUN install_packages \
    grep \
    psmisc \
    samba \
    util-linux

VOLUME ["/etc", \
    "/var/cache/samba", \
    "/var/lib/samba", \
    "/var/log/samba",\
    "/run/samba"]

COPY ./smb.conf /etc/samba/smb.conf
COPY ./start.sh /usr/local/bin/start.sh

CMD ["bash", "/usr/local/bin/start.sh", "--foreground", "--log-stdout", "--no-process-group"]
