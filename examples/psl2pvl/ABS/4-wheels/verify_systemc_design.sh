#!/bin/bash

cd "$(dirname "$0")"
SRC_PATH=$PWD/0-src
OUT_PATH=$PWD/1-VESUV-out
MAN_PATH=$PWD/2-manual
PREPARE_PATH=$PWD/3-prepare
VERIFY_PATH=$PWD/4-verify
VERCORS_PATH=$PWD/../../../../

# Verify SystemC design using VerCors
#echo "Verifying SystemC Design..."
#$VERCORS_PATH./bin/vct --more -q --dev-unsafe-optimization --dev-no-sat $VERIFY_PATH/*.pvl &> $PWD/verification_report.txt
