#!/bin/bash

# install mandatory python dependencies with pixi
pixi-add ${INST_SCRIPTS_DIR}/python.spec

CORE_PACKAGES=""

# install core dependencies for vvg-box installation
if ! [ -x "$(command -v readlink)" ] || defined_and_contains_any INCLUDE coreutils; then
  echo -e "\e[32m>>>> Will add coreutils\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} coreutils>=9.5,<10"
fi

if ! [ -x "$(command -v parallel)" ] || defined_and_contains_any INCLUDE parallel; then
  echo -e "\e[32m>>>> Will add parallel\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} parallel==20250422|20200322"
fi

if ! ([ -x "$(command -v cc)" ] && [ -x "$(command -v ar)" ]) || defined_and_contains_any INCLUDE "c-compiler"; then
  echo -e "\e[32m>>>> Will add gcc\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} gcc"
fi

if ! ([ -x "$(command -v c++)" ] && [ -x "$(command -v ar)" ]) || defined_and_contains_any INCLUDE "cxx-compiler"; then
  echo -e "\e[32m>>>> Will add gxx\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} gxx"
fi

if ! [ -x "$(command -v ar)" ] || defined_and_contains_any INCLUDE ar; then
  echo -e "\e[32m>>>> Will add binutils (for ar)\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} binutils"
fi

if ! [ -x "$(command -v make)" ] || defined_and_contains_any INCLUDE make; then
  echo -e "\e[32m>>>> Will add make\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} make"
fi

if ! [ -x "$(command -v cmake)" ] || defined_and_contains_any INCLUDE cmake; then
  echo -e "\e[32m>>>> Will add cmake\e[0m"
  CORE_PACKAGES="${CORE_PACKAGES} cmake"
fi

# if CORE_PACKAGES is not empty, install the packages with pixi
if [[ -n "${CORE_PACKAGES}" ]]; then
  echo -e "\e[32m>>>> Installing core dependencies: ${CORE_PACKAGES}\e[0m"
  retry 5 pixi global install ${CORE_PACKAGES} --environment core
else
  echo -e "\e[32m>>>> All vvg-box core dependencies are already satisfied, skipping installation\e[0m"
fi

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
