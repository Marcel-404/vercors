#!/bin/bash

cd "$(dirname "$0")"

trap 'exit 130' INT

PREPARE=3-prepare
VERCORS_PATH=$PWD/../../lib/RASI-Generator

generate_rasi(){
    SYSTEMCDESIGN="$1"
    RASI_VARS=$2
    INDEX=$3

    echo "[WARNING] Running this script will delete the old rasi.pvl in $PWD/$SYSTEMCDESIGN/$PREPARE!"
    while true; do
        read -p "[WARNING] Do you wish to continue? [y/n]" yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Yes or no answer required";;
        esac
    done

    # Generate RASI
    echo "[INFO] Generating RASI $INDEX for $SYSTEMCDESIGN..."
    rm $PWD/$SYSTEMCDESIGN/$PREPARE/RASI/rasi${INDEX}.pvl || true
    $VERCORS_PATH/./vercors --vesuv --generate-rasi --rasi-vars $RASI_VARS --vesuv-output $PWD/$SYSTEMCDESIGN/$PREPARE/RASI/rasi${INDEX}.pvl --verbose $PWD/$SYSTEMCDESIGN/$PREPARE/*.pvl
    
    # Remove min_advance
    grep -v "min_advance" $PWD/$SYSTEMCDESIGN/$PREPARE/RASI/rasi${INDEX}.pvl > $PWD/$SYSTEMCDESIGN/$PREPARE/RASI/tmp && mv $PWD/$SYSTEMCDESIGN/$PREPARE/RASI/tmp $PWD/$SYSTEMCDESIGN/$PREPARE/RASI/rasi${INDEX}.pvl
    echo ";" >> "$PWD/$SYSTEMCDESIGN/$PREPARE/RASI/rasi${INDEX}.pvl"
    echo "[INFO] To continue with the verification of the SystemC Design, rerun run_experiments.sh in mode Verify or run verify.sh."
}

printf "[INFO] Generate RASI for which SystemC Design?:\n"
printf "1) Automated/ABS/1-wheel\n2) Automated/ABS/4-wheels\n3) All SystemC designs\n4) Back to previous menu\n"
read -r option
case "$option" in
    1)  generate_rasi "Automated/ABS/1-wheel" "event_state[0],event_state[1],event_state[3],process_state[0],process_state[2],min_advance";;
    2)  generate_rasi "Automated/ABS/4-wheels" "event_state[0],event_state[1],event_state[8],process_state[0],process_state[6],min_advance" 1
        generate_rasi "Automated/ABS/4-wheels" "event_state[2],event_state[3],event_state[9],process_state[1],process_state[5],min_advance" 2
        generate_rasi "Automated/ABS/4-wheels" "event_state[4],event_state[5],event_state[10],process_state[2],process_state[8],min_advance" 3
        generate_rasi "Automated/ABS/4-wheels" "event_state[6],event_state[7],event_state[11],process_state[3],process_state[7],min_advance" 4;;
        
    #3) generate_rasi "Manual-Encoding/ABS/1-wheel" "event_state[0],event_state[3],process_state[0],process_state[2]";;
    #3) generate_rasi "producer-consumer" "";; 
    #4) generate_rasi "crossroad" "";; 
    3)  generate_rasi "Automated/ABS/1-wheel" "event_state[0],event_state[1],event_state[3],process_state[0],process_state[2],min_advance"
        generate_rasi "Automated/ABS/4-wheels" "event_state[0],event_state[1],event_state[8],process_state[0],process_state[6],min_advance" 1
        generate_rasi "Automated/ABS/4-wheels" "event_state[2],event_state[3],event_state[9],process_state[1],process_state[5],min_advance" 2
        generate_rasi "Automated/ABS/4-wheels" "event_state[4],event_state[5],event_state[10],process_state[2],process_state[8],min_advance" 3
        generate_rasi "Automated/ABS/4-wheels" "event_state[6],event_state[7],event_state[11],process_state[3],process_state[7],min_advance" 4
        #generate_rasi "Manual-Encoding/ABS/1-wheel" "event_state[0],event_state[3],process_state[0],process_state[2]"
        #generate_rasi "producer-consumer" "" 
        #generate_rasi "crossroad" ""
        ;; 
    5) $PWD/run_experiments.sh ;;
  *) echo "[ERROR] Invalid option" "";;
esac
