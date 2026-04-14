#!/bin/bash

cd "$(dirname "$0")"
VERIFY_SH=verify_systemc_design.sh

# Verify AST/1-wheel
echo "Verifying ABS/1-Wheel example..."
$PWD/ABS/1-wheel/$VERIFY_SH

# Verify AST/4-wheel
echo "Verifying ABS/4-Wheel example..."
$PWD/ABS/4-wheels/$VERIFY_SH

# Verify producer-consumer
echo "Verifying producer-consumer example..."
$PWD/producer-consumer/$VERIFY_SH

# Verify crossroad
echo "Verifying crossroad example..."
$PWD/crossroad/$VERIFY_SH
