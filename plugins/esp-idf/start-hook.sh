#!/bin/bash

# create service init file (sourced by %%service)
init_file=${HOME}/.init_esp-idf.sh
if [ ! -f $init_file ]; then
    echo 'echo setting up IDF ...' > $init_file
    echo '. $IDF_PATH/export.sh > /dev/null' >> $init_file
fi
