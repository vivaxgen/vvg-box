#!/bin/bash

# re-source activation script as early as possible to get access to
# all necessary environment variables and functions
echo "Resourcing vvg-box environment"
__IN_VVG_INSTALLATION__=1
source ${VVG_BASEDIR}/etc/bashrc

INST_SCRIPTS_DIR="${VVG_REPODIR}/etc/inst-scripts"

# install mandatory python dependencies with pixi
pixi-add ${INST_SCRIPTS_DIR}/python.spec

CORE_PACKAGES=""

# install core dependencies for vvg-box installation
if ! [ -x "$(command -v readlink)" ] || defined_and_contains_any INCLUDE coreutils; then
  echo "Will add coreutils"
  CORE_PACKAGES="${CORE_PACKAGES} coreutils>=9.5,<10"
fi

if ! [ -x "$(command -v parallel)" ] || defined_and_contains_any INCLUDE parallel; then
  echo "Will add parallel"
  CORE_PACKAGES="${CORE_PACKAGES} parallel==20250422|20200322"
fi

if ! ([ -x "$(command -v cc)" ] && [ -x "$(command -v ar)" ]) || defined_and_contains_any INCLUDE "c-compiler"; then
  echo "Will add gcc"
  CORE_PACKAGES="${CORE_PACKAGES} gcc"
fi

if ! ([ -x "$(command -v c++)" ] && [ -x "$(command -v ar)" ]) || defined_and_contains_any INCLUDE "cxx-compiler"; then
  echo "Will add gxx"
  CORE_PACKAGES="${CORE_PACKAGES} gxx"
fi

if ! [ -x "$(command -v ar)" ] || defined_and_contains_any INCLUDE ar; then
  echo "Will add binutils (for ar)"
  CORE_PACKAGES="${CORE_PACKAGES} binutils"
fi

if ! [ -x "$(command -v make)" ] || defined_and_contains_any INCLUDE make; then
  echo "Will add make"
  CORE_PACKAGES="${CORE_PACKAGES} make"
fi

if ! [ -x "$(command -v cmake)" ] || defined_and_contains_any INCLUDE cmake; then
  echo "Will add cmake"
  CORE_PACKAGES="${CORE_PACKAGES} cmake"
fi

# if CORE_PACKAGES is not empty, install the packages with pixi
if [[ -n "${CORE_PACKAGES}" ]]; then
  echo "Installing core dependencies: ${CORE_PACKAGES}"
  retry 5 pixi global install ${CORE_PACKAGES} --environment core
else
  echo "All vvg-box core dependencies are already satisfied, skipping installation"
fi

# check if VVG_EXCLUDE variable is not set or if it does not contain "snakemake"

if ! defined_and_contains_any VVG_EXCLUDE snakemake; then
  echo "Installing snakemake and related dependencies"
  retry 5 pixi workspace channel add bioconda
  #retry 5 pixi add "snakemake>=9.20" snakemake-executor-plugin-cluster-generic
  pixi-add ${INST_SCRIPTS_DIR}/snakemake.spec
else
  echo "snakemake is excluded, skipping installation"
fi

# prepare activation file
echo "Preparing activation source file"
${ENVS_DIR}/vvg-box/bin/generate-activation-script.py

# all the following run under active vvg-box environment
${VVGBIN}/generate-executable-links.py
${VVGBIN}/link-resource-files.sh ${ENVS_DIR}/vvg-box/etc/bashrc.d

# check if we are provided with SPECDIR
if [[ -z ${SPECDIR:-} ]]; then
  echo "Using default packages"
else
  echo "Using specification directory ${SPECDIR} to install packages"
  ${VVGBIN}/install-from-specdir.py
fi

echo "Detecting job/batch scheduler"
${ENVS_DIR}/vvg-box/bin/set-snakemake-profile.py

# EOF
