#!/bin/bash

cd "$(dirname "$0")"
SRC_PATH=$PWD/0-src
OUT_PATH=$PWD/1-VESUV-out
MAN_PATH=$PWD/2-manual
PREPARE_PATH=$PWD/3-prepare
VERIFY_PATH=$PWD/4-verify
VERCORS_PATH=$PWD/../../../../

# Generate RASI
echo "Generating RASI..."
#$VERCORS_PATH./bin/vct --vesuv --generate-rasi --rasi-vars event_state[0],event_state[3],process_state[0],process_state[2] --vesuv-output $PREPARE_PATH/rasi.pvl --verbose $PREPARE_PATH/*.pvl

# Remove min_advance
#$PREPARE_PATH/remove-min_advance.sh