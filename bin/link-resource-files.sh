#!/bin/bash

# check if no argument is given, if so, print usage and exit with error code 1
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# for each file in the first argument of this script, generate a link to ${VVG_BASEDIR}/etc/bashrc.d/

for file in "$1"/*; do
    if [ -f "$file" ]; then
        echo "Linking $file to ${VVG_BASEDIR}/etc/bashrc.d/$(basename "$file")"
        ln -srf "$file" "${VVG_BASEDIR}/etc/bashrc.d/$(basename "$file")"
    fi
done

# EOF