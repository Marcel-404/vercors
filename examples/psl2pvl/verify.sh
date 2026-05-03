#!/bin/bash

cd "$(dirname "$0")"

trap 'exit 130' INT

VERIFY_PATH=4-verify
VERCORS_PATH=$PWD/../../

verify(){
    SYSTEMCDESIGN="$1"
    printf "[INFO] Verifying $SYSTEMCDESIGN...\n"
    $VERCORS_PATH./bin/vct --more -q --dev-unsafe-optimization --dev-no-sat $PWD/$SYSTEMCDESIGN/$VERIFY_PATH/*.pvl &> $PWD/$SYSTEMCDESIGN/verification_report.txt
    printf "[INFO] Verification report stored in $PWD/$SYSTEMCDESIGN/verification_report.txt\n"
}

printf "[INFO] Verify which SystemC design?:\n"
printf "1) Automated/ABS/1-wheel\n2) Automated/ABS/4-wheels\n3) Manual-Encoding/ABS/1-wheel\n4) Manual-Encoding/ABS/4-wheels\n5) All SystemC designs\n6) Back to previous menu\n"
read -r option
case "$option" in
  1) verify "Automated/ABS/1-wheel" ;;
  2) verify "Automated/ABS/4-wheels" ;;
  3) verify "Manual-Encoding/ABS/1-wheel";;
  4) verify "Manual-Encoding/ABS/4-wheels";;
  #3) verify "producer-consumer" ;;
  #4) verify "crossroad" ;;
  5) 
    verify "Automated/ABS/1-wheel"
    verify "Automated/ABS/4-wheels"
    verify "Manual-Encoding/ABS/1-wheel"
    verify "Manual-Encoding/ABS/4-wheels";;
    #verify "producer-consumer"
    #verify "crossroad" ;;
6) $PWD/run_experiments.sh ;;
  *) printf "[ERROR] Invalid option\n" ;;
esac
