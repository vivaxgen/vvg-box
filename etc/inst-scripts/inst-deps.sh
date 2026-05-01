#!/bin/bash

# install core dependencies for vvg-box installation
if ! [ -x "$(command -v readlink)" ] || defined_and_contains_any INCLUDE coreutils; then
  echo "Installing coreutils"
  micromamba -y install "coreutils>=9.5,<10" -c conda-forge -c defaults
fi

if ! [ -x "$(command -v parallel)" ] || defined_and_contains_any INCLUDE parallel; then
  echo "Installing parallel"
  micromamba -y install "parallel==20250422|20200322" -c conda-forge -c defaults
fi

if ! ([ -x "$(command -v cc)" ] && [ -x "$(command -v ar)" ]) || defined_and_contains_any INCLUDE "c-compiler"; then
  echo "Installing essential c-compiler"
  retry 5 micromamba -y install "c-compiler>=1.9.0,<2" -c conda-forge
fi

if ! ([ -x "$(command -v c++)" ] && [ -x "$(command -v ar)" ]) || defined_and_contains_any INCLUDE "cxx-compiler"; then
  echo "Installing essential cxx-compiler"
  retry 5 micromamba -y install "cxx-compiler>=1.9.0,<2" -c conda-forge
fi

# install other dependencies with micromamba
retry 5 micromamba -y install -n ${uMAMBA_ENVNAME} -f ${ENVS_DIR}/vvg-box/etc/inst-scripts/env.yaml python=${PYVER}

# check if EXCLUDE variable is not set or if it does not contain "snakemake"

if [[ -z ${EXCLUDE:-} ]] || [[ ! ${EXCLUDE} == *"snakemake"* ]]; then
  echo "Installing snakemake and related dependencies"
  retry 5 micromamba -y install -n ${uMAMBA_ENVNAME} -f ${ENVS_DIR}/vvg-box/etc/inst-scripts/env-2.yaml
else
  echo "snakemake is excluded, skipping installation"
fi

# prepare activation file
echo "Preparing activation source file"
${ENVS_DIR}/vvg-box/bin/generate-activation-script.py

# re-source activation script
echo "Resourcing vvg-box environment"
export VVG_BASEDIR=${BASEDIR}
__IN_VVG_INSTALLATION__=1
source ${VVG_BASEDIR}/etc/bashrc

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
