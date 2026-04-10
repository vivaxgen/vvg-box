#!/bin/bash
# for each file in in ${VVG_BASEDIR}/envs/*/etc/bashrc.d/, generate a link to ${VVG_BASEDIR}/etc/bashrc.d/

for file in ${VVG_BASEDIR}/envs/*/etc/bashrc.d/*; do
    if [ -f "$file" ]; then
        echo "Linking $file to ${VVG_BASEDIR}/etc/bashrc.d/$(basename "$file")"
        ln -srf "$file" "${VVG_BASEDIR}/etc/bashrc.d/$(basename "$file")"
    fi
done

# EOF