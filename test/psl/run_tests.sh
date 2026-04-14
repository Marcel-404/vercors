#!/bin/bash

cd "$(dirname "$0")"
javac -d out Main.java
cd "$PWD/../.."
echo "Transforming PSL expressions..."
java -cp out test.psl.Main
echo "Transformation complete."