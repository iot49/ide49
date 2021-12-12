#! /bin/ash

mkdir -p /mosquitto/config
mkdir -p /mosquitto/data
mkdir -p /mosquitto/log

# install default configuration
if [ ! -f /mosquitto/.config_v1 ]; then
    cp /usr/local/src/mosquitto.conf /mosquitto/config
    echo 'mosquitto config v1 installed' >/mosquitto/.config_v1
fi

# customize device environment (e.g. SAMBA_PASSWORD)
env49rc=/service-config/iot-home/.env49rc
if [ -f $env49rc ]; then
    echo sourcing $env49rc ...
    source $env49rc
fi

# start the broker
if [ ${MOSQUITTO:=on}  == on ]; then
    /usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf
fi
