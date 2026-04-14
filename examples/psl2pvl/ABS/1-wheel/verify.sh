#! /bin/sh

#CURR="$(dirname "$0")"
rm $PWD/src/main_ast

rm $PWD/src/main_ast.ast.xml

# Translate SystemC and PSL into AST
echo "Generating AST file for example ABS/1-wheel..."
java -jar $PWD/../../../sc2ast.jar -f $PWD/src/ABS_tb.cpp -i $PWD/src/ABSASR.h $PWD/src/TickCounter.h $PWD/src/settings.h -o $PWD/src/main_ast

echo "Generating PVL files for AST file of example ABS/1-wheel..."
# Remove previous translation results
rm $PWD/out/*.pvl

# Run VESUV transformation to transform PSL annotations and SystemC desing
$PWD/../../../../.bin/vct --vesuv --vesuv-output $PWD/out/ $PWD/src/main_ast.ast.xml

# Manual Steps 

# Generate RASI
$PWD/../../../../.bin/vct --vesuv --generate-rasi --rasi-vars event_state[0],event_state[3],process_state[0],process_state[2] --vesuv-output examples/psl2pvl/<example>/verify/rasi.pvl --verbose examples/psl2pvl/<example>/verify/prepared/*.pvl

# Remove min_advance
#$PWD/03-verify/remove-min_advance.sh

#echo "Verifying SystemC Design..."
# Run VerCors (WARNING LONG RUNTIME)
#$PWD/03-verify/verify.sh
