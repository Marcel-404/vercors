#!/bin/bash

    while true; do
        read -p "[INFO] Measure average transformation duration? [y/n] " yn
        case $yn in
            [Yy]* ) echo "50"; break;;
            [Nn]* ) echo "1"; break;;
            * ) printf "Yes or no answer required\n";;
        esac
    done

