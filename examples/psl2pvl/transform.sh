#!/bin/bash

cd "$(dirname "$0")"

trap 'exit 130' INT

VERCORS_PATH=$PWD/../../
SC2AST_PATH=$PWD/../../lib/
SRC="0-src"
OUT="1-VESUV-out"

transform(){
    SYSTEMCDESIGN="$1"

    printf "[WARNING] Running this script will delete the old SystemC2AST transformation in $PWD/$SYSTEMCDESIGN/$SRC and the old VESUV output in $PWD/$SYSTEMCDESIGN/$OUT!\n"
    while true; do
        read -p "[WARNING] Do you wish to continue? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) printf "Yes or no answer required";;
        esac
    done

    # Generate AST
    printf "[INFO] Generating AST for the SystemC design $SYSTEMCDESIGN...\n"
    rm $PWD/$SYSTEMCDESIGN/$SRC/main_ast.ast.xml || true
    rm $PWD/$SYSTEMCDESIGN/$SRC/main_ast || true
    java -jar $SC2AST_PATH/sc2ast.jar -f $PWD/$SYSTEMCDESIGN/$SRC/*.cpp -i $PWD/$SYSTEMCDESIGN/$SRC/*.h -o $PWD/$SYSTEMCDESIGN/$SRC/main_ast

    # Generate VESUV output
    printf "[INFO] Generating VESUV output from AST of SystemC design $SYSTEMCDESIGN...\n"
    rm $PWD/$SYSTEMCDESIGN/$OUT/*.pvl || true
    $VERCORS_PATH./bin/vct --vesuv --vesuv-output $PWD/$SYSTEMCDESIGN/$OUT/ $PWD/$SYSTEMCDESIGN/$SRC/main_ast.ast.xml

    printf "[INFO] To continue with the verification of the VESUV output, manual steps are needed in folders 2-manual and 3-prepare.\n"
    printf "[INFO] After manual steps are complete, rerun run_experiments.sh in mode Generate RASI or run generate_rasi.sh\n"
}

printf "[INFO] Transform which SystemC design?:\n"
printf "1) ABS/1-wheel\n2) ABS/4-wheels\n3) producer-consumer\n4) crossroad\n5) All SystemC designs\n6) Back to previous menu\n"
read -r option
case "$option" in
  1) transform "ABS/1-wheel" ;;
  2) transform "ABS/4-wheels" ;;
  3) transform "producer-consumer" ;;
  4) transform "crossroad" ;;
  5) 
    transform "ABS/1-wheel"
    transform "ABS/4-wheels"
    transform "producer-consumer"
    transform "crossroad" ;;
6) $PWD/run_experiments.sh ;;
  *) printf "[ERROR] Invalid option\n" ;;
esac