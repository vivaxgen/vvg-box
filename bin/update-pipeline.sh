#!/usr/bin/env bash

echo "Updating all sofware packages under $VVG_BASEDIR/envs..."
for p in $VVG_BASEDIR/envs/*; do
    if [ -d "$p" ]; then
        echo "Updating ${p}"
        (cd "$p"; git pull)
    fi
done
unset p

echo "Updating finished."

