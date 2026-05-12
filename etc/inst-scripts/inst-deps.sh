#!/bin/bash

# install mandatory python dependencies with pixi
echo -e "\e[32m>>>> Installing mandatory python dependencies\e[0m"
pixi-add ${INST_SCRIPTS_DIR}/python.spec


# check if VVG_EXCLUDE variable is not set or if it does not contain "snakemake"
if ! defined_and_contains_any VVG_EXCLUDE snakemake; then
  echo -e "\e[32m>>>> Installing snakemake and related dependencies\e[0m"
  retry 5 pixi workspace channel add bioconda
  #retry 5 pixi add "snakemake>=9.20" snakemake-executor-plugin-cluster-generic
  pixi-add ${INST_SCRIPTS_DIR}/snakemake.spec
else
  echo -e "\e[32m>>>> snakemake is excluded, skipping installation\e[0m"
fi

# EOF
