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
printf "1) Automated/ABS/1-wheel\n2) Automated/ABS/4-wheels\n3) Automated/ABS/1-wheel-Alternative\n4) VESUV-Encoding/ABS/1-wheel\n5) VESUV-Encoding/ABS/4-wheels\n6) All SystemC designs\n7) Back to previous menu\n"
read -r option
case "$option" in
  1) verify "Automated/ABS/1-wheel" ;;
  2) verify "Automated/ABS/4-wheels" ;;
  3) verify "Automated/ABS/1-wheel-Alternative" ;;
  4) verify "VESUV-Encoding/ABS/1-wheel";;
  5) verify "VESUV-Encoding/ABS/4-wheels";;
  #3) verify "producer-consumer" ;;
  #4) verify "crossroad" ;;
  6) 
    verify "Automated/ABS/1-wheel"
    verify "Automated/ABS/4-wheels"
    verify "Automated/ABS/1-wheel-Alternative" 
    verify "VESUV-Encoding/ABS/1-wheel"
    verify "VESUV-Encoding/ABS/4-wheels";;
    #verify "producer-consumer"
    #verify "crossroad" ;;
7) $PWD/run_experiments.sh ;;
  *) printf "[ERROR] Invalid option\n" ;;
esac
