#! /bin/ash

mkdir -p /mosquitto/config
mkdir -p /mosquitto/data
mkdir -p /mosquitto/log

# install default configuration
if [[ ! -f /mosquitto/.config_v1 ]]; then
    cp /usr/local/src/mosquitto.conf /mosquitto/config
    echo 'mosquitto config v1 installed' >/mosquitto/.config_v1
fi

# start the broker
/usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf
