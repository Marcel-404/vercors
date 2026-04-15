#!/bin/bash

cd "$(dirname "$0")"
javac -d out Main.java
cd "$PWD/../.."
echo "[INFO] Transforming PSL expressions..."
java -cp out test.psl.Main
echo "[INFO] Transformation complete."