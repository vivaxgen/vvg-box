#!/bin/bash
# for each file in in ${VVG_BASE}/envs/*/etc/bashrc.d/, generate a link to ${VVG_BASE}/etc/bashrc.d/

for file in ${VVG_BASE}/envs/*/etc/bashrc.d/*; do
    if [ -f "$file" ]; then
        echo "Linking $file to ${VVG_BASE}/etc/bashrc.d/$(basename "$file")"
        ln -srf "$file" "${VVG_BASE}/etc/bashrc.d/$(basename "$file")"
    fi
done

# EOF