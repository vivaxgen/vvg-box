#!/usr/bin/env bash

# optional env variables:
# - BASEDIR
# - PIXI_ENVNAME
# - PYVER

__VERSION__='2026.05.08.01'
echo "vivaxGEN Box installation script version: ${__VERSION__}"

set -eu

# check if we are under CONDA environment, and exit if we are
if [[ ${CONDA_SHLVL:-} -ge 1 ]]; then
  echo "Cannot perform installation while under an active conda/mamba environment."
  echo "Please deactivate the environment first."
  exit 1
fi

# check if we are under pixi environment, and exit if we are
if [[ ${PIXI_ENVIRONMENT_NAME:-} != "" ]]; then
  echo "Cannot perform installation while under an active pixi environment."
  echo "Please deactivate the environment first."
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
PYVER="${PYVER:-3.12}"

mkdir -p "${BINDIR}"
PATH="${PIXI_HOME}/bin:${BINDIR}:${PATH}"

echo "Setting up base directory structure at ${VVG_BASEDIR}"

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
  echo "pixi not found in PATH, installing a local pixi binary..."
  if hash curl >/dev/null 2>&1; then
    curl -fsSL https://pixi.sh/install.sh | PIXI_HOME="${PIXI_HOME}" PIXI_BIN_DIR="${BINDIR}" PIXI_NO_PATH_UPDATE=1 bash
  elif hash wget >/dev/null 2>&1; then
    wget -qO- https://pixi.sh/install.sh | PIXI_HOME="${PIXI_HOME}" PIXI_BIN_DIR="${BINDIR}" PIXI_NO_PATH_UPDATE=1 bash
  else
    echo "Neither curl nor wget was found, cannot bootstrap pixi." >&2
    exit 1
  fi
fi


echo "vvg-box" >> "${ETC_DIR}"/installed-repo.txt

# save installation environment variables
# other installation scripts can append this file

vars_to_save=(PYVER EXCLUDE INCLUDE OMIT)

# Loop through and save them safely while `set -u` is enabled
for var in "${vars_to_save[@]}"; do
  # Use indirect expansion with a default so unset variables expand to empty
  echo "$var='${!var:-}'" >> "${ETC_DIR}/inst-envvars"
done

# generate initial pixi enviroment
echo "Initializing pixi environment at ${VVG_PIXI_WORKSPACE_DIR}"
pixi init ${VVG_PIXI_WORKSPACE_DIR}
echo "Activating pixi environment ${PIXI_ENVNAME}"
eval "$(pixi shell-hook --manifest-path "${VVG_PIXI_WORKSPACE_DIR}/pixi.toml")"

if ! [ -x "$(command -v git)" ]; then
  echo "Installing git"
  pixi global install --environment core "git>=2.49,<3" -c conda-forge
fi

# install vvg-box repo as early as possible, so that we can use its helper functions in subsequent installation scripts
echo "Cloning vivaxGEN vvg-box repository"
# For dev: add --branch dev

# VVG_URLREPO can be set to a custom repository URL, for example to install from a fork or a specific branch
VVG_REPOURL="${VVG_REPOURL:-https://github.com/vivaxgen/vvg-box.git}"

git clone --depth 1 "${VVG_REPOURL}" "${ENVS_DIR}"/vvg-box
ln -sr "${ENVS_DIR}"/vvg-box/etc/bashrc "${ETC_DIR}"/bashrc

# source the helper functions for use in this script
source "${ENVS_DIR}"/vvg-box/etc/functions

source "${ENVS_DIR}"/vvg-box/etc/inst-scripts/inst-deps.sh

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
echo "    $(realpath "${BINDIR}")/exec micromamba list"
echo

# EOF
