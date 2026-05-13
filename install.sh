#!/usr/bin/env bash

# optional env variables:
# - VVG_BASEDIR
# - PIXI_ENVNAME
# - VVG_EXCLUDE
# - VVG_INCLUDE
# - VVG_MANIFEST_FILE
# - VVG_REPOURL

__VERSION__='2026.05.08.01'
echo -e "\e[32m>> vivaxGEN vvg-box installation script version: ${__VERSION__}\e[0m"

set -eu

# check if we are under CONDA environment, and exit if we are
if [[ ${CONDA_SHLVL:-} -ge 1 ]]; then
  echo -ne "\e[31m"
  echo "Cannot perform installation while under an active conda/mamba environment."
  echo "Please deactivate the environment first."
  echo -ne "\e[0m"
  exit 1
fi

# check if we are under pixi environment, and exit if we are
if [[ ${PIXI_ENVIRONMENT_NAME:-} != "" ]]; then
  echo -ne "\e[31m"
  echo "Cannot perform installation while under an active pixi environment."
  echo "Please deactivate the environment first."
  echo -e "\e[0m"
  exit 1
fi

# Parsing arguments
if [ -t 0 ] && [ -z "${VVG_BASEDIR:-}" ]; then
  printf "Base directory? [./vvg-box] "
  read -r VVG_BASEDIR
fi

if [ -t 0 ] && [ -z "${PIXI_ENVNAME:-}" ]; then
  printf "pixi environment name? [vvg-box] "
  read -r PIXI_ENVNAME
fi

# Fallbacks
export VVG_BASEDIR="${VVG_BASEDIR:-./vvg-box}"
VVG_BASEDIR="$(realpath "${VVG_BASEDIR}")"
BINDIR="${VVG_BASEDIR}/bin"
export PIXI_ENVNAME="${PIXI_ENVNAME:-vvg-box}"

# see https://pixi.prefix.dev/latest/reference/environment_variables/
# set PIXI_HOME to a directory where pixi can store its data, such as installed environments and caches
PIXI_DIR="${VVG_BASEDIR}/opt/pixi"
VVG_PIXI_WORKSPACE_DIR="${PIXI_DIR}/${PIXI_ENVNAME}"
export PIXI_HOME="${PIXI_DIR}/global"
export PIXI_CACHE_DIR="${PIXI_DIR}/.cache"
export PIP_CACHE_DIR="${PIXI_DIR}/.cache-pip"
export RATTLER_AUTH_FILE="${PIXI_CACHE_DIR}/.rattler-credentials.json"

# defaults
export PYVER="${PYVER:-3.12}"

mkdir -p "${BINDIR}"
PATH="${PIXI_HOME}/bin:${BINDIR}:${PATH}"

echo -e "\e[32m>> Setting up base directory structure at ${VVG_BASEDIR}\e[0m"

export OPT_DIR="${VVG_BASEDIR}/opt"
export APPTAINER_DIR="${VVG_BASEDIR}/opt/apptainer"
export ENVS_DIR="${VVG_BASEDIR}/envs"
export ETC_DIR="${VVG_BASEDIR}/etc"
export BASHRC_DIR="${ETC_DIR}/bashrc.d"
export SNAKEMAKEPROFILE_DIR="${ETC_DIR}/snakemake-profiles"

mkdir -p "${OPT_DIR}"
mkdir -p "${APPTAINER_DIR}"
mkdir -p "${ENVS_DIR}"
mkdir -p "${ETC_DIR}"
mkdir -p "${BASHRC_DIR}"
mkdir -p "${SNAKEMAKEPROFILE_DIR}"
mkdir -p "${VVG_PIXI_WORKSPACE_DIR}" "${PIXI_HOME}" "${PIXI_CACHE_DIR}" "${PIP_CACHE_DIR}"

# check if pixi is available, and if not, install a local pixi binary
if ! [ -x "$(command -v pixi)" ]; then
  echo -e "\e[32m>> pixi not found in PATH, installing a local pixi binary...\e[0m"
  if hash curl >/dev/null 2>&1; then
    curl -fsSL https://pixi.sh/install.sh | PIXI_HOME="${PIXI_HOME}" PIXI_BIN_DIR="${BINDIR}" PIXI_NO_PATH_UPDATE=1 bash
  elif hash wget >/dev/null 2>&1; then
    wget -qO- https://pixi.sh/install.sh | PIXI_HOME="${PIXI_HOME}" PIXI_BIN_DIR="${BINDIR}" PIXI_NO_PATH_UPDATE=1 bash
  else
    echo "ERROR: Neither curl nor wget was found, cannot bootstrap pixi." >&2
    exit 1
  fi
fi

# generate initial pixi enviroment
echo -e "\e[32m>> Initializing pixi environment at ${VVG_PIXI_WORKSPACE_DIR}\e[0m"
pixi init ${VVG_PIXI_WORKSPACE_DIR} ${PIXI_OVERRIDE_PLATFORM:+--platform $PIXI_OVERRIDE_PLATFORM}
echo -e "\e[32m>> Activating pixi environment ${PIXI_ENVNAME}\e[0m"
eval "$(pixi shell-hook --manifest-path "${VVG_PIXI_WORKSPACE_DIR}/pixi.toml")"

# at this point, pixi global and workspace environments are active,
# so we can use pixi to install dependencies

if ! [ -x "$(command -v git)" ]; then
  echo -e "\e[32m>> Installing git\e[0m"
  pixi global install --environment core "git>=2.49,<3" -c conda-forge
fi

# install vvg-box repo as early as possible, so that we can use its helper functions in subsequent installation scripts
echo -e "\e[32m>> Cloning vivaxGEN vvg-box repository\e[0m"
# For dev: add --branch dev

# VVG_URLREPO can be set to a custom repository URL, for example to install from a fork or a specific branch
VVG_REPOURL="${VVG_REPOURL:-https://github.com/vivaxgen/vvg-box.git}"

git clone --depth 1 "${VVG_REPOURL}" "${ENVS_DIR}"/vvg-box
ln -sr "${ENVS_DIR}"/vvg-box/etc/bashrc "${ETC_DIR}"/bashrc

# source the helper functions for use in this script
source "${ENVS_DIR}"/vvg-box/etc/functions

# save installation environment variables
# other installation scripts can append this file
save_env_vars PYVER VVG_EXCLUDE VVG_INCLUDE

echo "vvg-box" >> "${ETC_DIR}"/installed-repo.txt
echo -e "\e[32m>> Executing stage-2 of installation\e[0m"
source "${ENVS_DIR}"/vvg-box/etc/inst-scripts/inst-stage-2.sh

echo
echo "vivaxGEN Box (vvg-box) has been successfully installed."
echo "To activate the environment, either run the activation script"
echo "to spawn a new shell:"
echo
echo "    $(realpath "${BINDIR}/activate")"
echo
echo "or source the activation script (eg. inside another script):"
echo
echo "    source $(realpath "${BINDIR}/activate")"
echo
echo "or execute a software directly:"
echo
echo "    $(realpath "${BINDIR}")/exec software [ARGS ...]"
echo
echo "example:"
echo
echo "    $(realpath "${BINDIR}")/exec pixi list"
echo

# EOF
