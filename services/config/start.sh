#! /bin/bash

# install default configuration if no configuration found

cd /service-config/config

rsync --update -a /usr/local/src/config/. .

# make sure we have a secrets file
touch secrets.yaml

# fix permissions
addgroup -g 2000 config
chown -R root:config .
chmod -R g+w .
chmod -R a+rx bin

# keep the serive running forever ...
sleep infinity