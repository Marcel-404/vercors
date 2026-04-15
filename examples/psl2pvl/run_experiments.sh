#!/bin/bash

cd "$(dirname "$0")"

trap 'exit 130' INT

printf "[INFO] Choose one of the following modes:\n"
printf "1) Transform SystemC design\n2) Generate RASI\n3) Verify SystemC design\n"
read -r mode
case "$mode" in
  1) $PWD/transform.sh ;;
  2) $PWD/generate_rasi.sh ;;
  3) $PWD/verify.sh ;;
  *) printf "[ERROR] Invalid option\n" ;;
esac