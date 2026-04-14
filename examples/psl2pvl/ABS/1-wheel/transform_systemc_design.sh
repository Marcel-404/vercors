SRC_PATH=$PWD/0-src
OUT_PATH=$PWD/1-VESUV-out
MAN_PATH=$PWD/2-manual
PREPARE_PATH=$PWD/3-prepare
VERIFY_PATH=$PWD/4-verify
VERCORS_PATH=$PWD/../../../../
#SC2AST_PATH =
# Remove old sc2ast output
#rm SRC_PATH/main_ast.ast.xml
#rm SRC_PATH/main_ast


# Translate SystemC and PSL annotations into AST
#echo "Generating AST file for example ABS/1-wheel..."
#java -jar $S2AST_PATH/sc2ast.jar -f $SRC_PATH/ABS_tb.cpp -i $PWD/SRC_PATH/ABSASR.h $PWD/SRC_PATH/TickCounter.h $PWD/SRC_PATH/settings.h -o $PWD/SRC_PATH/main_ast

# echo "Generating PVL files for AST file of example ABS/1-wheel..."
# Remove previous VESUV transformation
#rm $OUT_PATH/*.pvl

# Run VESUV transformation to transform PSL annotations and SystemC design
$VERCORS_PATH./bin/vct --vesuv --vesuv-output $OUT_PATH/ $SRC_PATH/main_ast.ast.xml

# Manual Steps 
echo "Manual steps are needed to optimise and encode output in folders 2-manual and 3-prepare!"
echo "After manual steps are complete, run verify_systemc_design.sh!"