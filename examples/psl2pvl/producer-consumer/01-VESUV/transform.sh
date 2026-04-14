#! /bin/sh

CURR="$(dirname "$0")"

# Remove previous translation results
rm $CURR/output/*.pvl

# Run VeSUV transformation
vercors --vesuv --vesuv-output $CURR/output $CURR/../00-src/prod_cons_ast.ast.xml
