#!/usr/bin/env bash

echo "Exporting environment to $VVG_BASEDIR/etc/env.yaml"
micromamba env export > $VVG_BASEDIR/etc/env.yaml

