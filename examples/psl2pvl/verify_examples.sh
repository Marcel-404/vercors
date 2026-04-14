#! /bin/sh

#CURR="$(dirname "$0")"

# Verify AST/1-wheel
echo "Verifying ABS/1-Wheel example..."
$PWD/ABS/1-wheel/verify.sh

# Verify AST/4-wheel
echo "Verifying ABS/4-Wheel example..."
$PWD/ABS/4-wheel/verify.sh

# Verify producer-consumer
echo "Verifying producer-consumer example..."
$PWD/producer-consumer/verify.sh

# Verify crossroad
echo "Verifying crossroad example..."
$PWD/crossroad/verify.sh
