#! /bin/bash

# install default configuration if no configuration found

config_dir=/service-config/config

rsync --update -a /usr/local/src/config/. ${config_dir}
chmod a+rx ${config_dir}/bin

# make sure we have a secrets file
touch ${config_dir}/secrets.yaml

# keep the serive running forever ...
sleep infinity