#!/bin/bash

cd "$(dirname "$0")"

trap 'exit 130' INT

PREPARE=3-prepare
VERCORS_PATH=$PWD/../../lib/RASI-Generator

generate_rasi(){
    SYSTEMCDESIGN="$1"
    RASI_VARS=$2

    echo "[WARNING] Running this script will delete the old rasi.pvl in $PWD/$SYSTEMCDESIGN/$PREPARE!"
    while true; do
        read -p "[WARNING] Do you wish to continue? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Yes or no answer required";;
        esac
    done

    # Generate RASI
    echo "[INFO] Generating RASI for $SYSTEMCDESIGN..."
    rm $PWD/$SYSTEMCDESIGN/$PREPARE/rasi.pvl || true
    $VERCORS_PATH/./vercors --vesuv --generate-rasi --rasi-vars $RASI_VARS --vesuv-output $PWD/$SYSTEMCDESIGN/$PREPARE/rasi.pvl --verbose $PWD/$SYSTEMCDESIGN/$PREPARE/*.pvl
    
    # Remove min_advance
    grep -v "min_advance" $PWD/$SYSTEMCDESIGN/$PREPARE/rasi.pvl > $PWD/$SYSTEMCDESIGN/$PREPARE/tmp && mv $PWD/$SYSTEMCDESIGN/$PREPARE/tmp $PWD/$SYSTEMCDESIGN/$PREPARE/rasi.pvl

    echo "[INFO] To continue with the verification of the SystemC Design, rerun run_experiments.sh in mode Verify or run verify.sh."
}

printf "[INFO] Generate RASI for which SystemC Design?:\n"
printf "1) Automated/ABS/1-wheel\n2) Automated/ABS/4-wheels\n3) Manual-Encoding/ABS/1-wheel\n4) All SystemC designs\n5) Back to previous menu\n"
read -r option
case "$option" in
    1) generate_rasi "Automated/ABS/1-wheel" "event_state[0],event_state[3],process_state[0],process_state[2]";;
    2) generate_rasi "Automated/ABS/4-wheels" "";; # TODO
    3) generate_rasi "Manual-Encoding/ABS/1-wheel" "event_state[0],event_state[3],process_state[0],process_state[2]";;
    #3) generate_rasi "producer-consumer" "";; # TODO
    #4) generate_rasi "crossroad" "";; # TODO
    4)  generate_rasi "Automated/ABS/1-wheel" "event_state[0],event_state[3],process_state[0],process_state[2]"
        generate_rasi "Automated/ABS/4-wheels" "" # TODO
        generate_rasi "Manual-Encoding/ABS/1-wheel" "event_state[0],event_state[3],process_state[0],process_state[2]"
        #generate_rasi "producer-consumer" "" 
        #generate_rasi "crossroad" ""
        ;; 
    5) $PWD/run_experiments.sh ;;
  *) echo "[ERROR] Invalid option" "";;
esac
