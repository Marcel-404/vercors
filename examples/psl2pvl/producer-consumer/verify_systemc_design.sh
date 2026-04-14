#! /bin/sh
#CURR="$(dirname "$0")"
sudo rm $PWD/00-src/prod_cons_ast

sudo rm $PWD/00-src/prod_cons_ast.ast.xml

# Translate SystemC and PSL into AST
echo "Generating AST file for folder 00-src..."
java -jar $PWD/../../sc2ast.jar -f $PWD/00-src/prod_cons.cpp -i $PWD/00-src/consumer.h $PWD/00-src/myfifo.h $PWD/00-src/producer.h -o $PWD/00-src/prod_cons_ast

echo "Generating PVL files for AST file in folder 00-src..."
# Remove previous translation results
sudo rm $PWD/01-VESUV/output/*.pvl

# Run VeSUV transformation
sudo vercors --vesuv --vesuv-output $PWD/01-VESUV/output $PWD/00-src/prod_cons_ast.ast.xml

# Run VPSL transformation 

echo "Generating RASI..."
# Remove previous RASI
rm $PWD/rasi1.pvl

# Generates four RASIs, each specific to a given timing property of one of the four sensors.
#$PWD/../../../vercors --vesuv --generate-rasi --rasi-vars event_state[0],event_state[1],event_state[2],event_state[4],min_advance --vesuv-output $PWD/02-VPSL/rasi1.pvl --verbose $PWD/03-verify/prepared/*.pvl

# Remove min_advance
#grep -v "min_advance" $PWD/02-VPSL/rasi1.pvl > tmp && mv tmp $PWD/02-VPSL/rasi1.pvl

echo "Verifying SystemC Design..."
# Run VerCors
#sudo vercors --quiet $PWD/03-verify/finished/*.pvl
# Run VerCors (WARNING LONG RUNTIME)
#/usr/bin/time --format="Verification finished in %E" $PWD../../.././vercors --more -q --dev-unsafe-optimization --dev-no-sat $PWD/03-verify/finished/*.pvl &> $PWD/03-verify/verification_report.txt
