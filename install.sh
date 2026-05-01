#!/usr/bin/env bash

# below is ripped-off from micro.mamba.pm/install.sh

# optional env variables:
# - BASEDIR
# - MAMBA_ROOT_PREFIX
# - uMAMBA_ENVNAME
# - PYVER

__VERSION__='2026.05.01.01'
echo "vivaxGEN Box installation script version: ${__VERSION__}"

set -eu

# check if we are under CONDA environment, and exit if we are
if [[ ${CONDA_SHLVL:-} -ge 1 ]]; then
  echo "Cannot perform installation while under an active CONDA environment."
  echo "Please deactivate the environment first."
  exit 1
fi

# Detect the shell from which the script was called
parent=$(ps -o comm $PPID |tail -1)
parent=${parent#-}  # remove the leading dash that login shells have
case "$parent" in
  # shells supported by `micromamba shell init`
  bash|fish|xonsh|zsh)
    shell=$parent
    ;;
  *)
    # use the login shell (basename of $SHELL) as a fallback
    shell=${SHELL##*/}
    ;;
esac

# Parsing arguments
if [ -t 0 ] && [ -z "${BASEDIR:-}" ]; then
  printf "Base directory? [./vvg-box] "
  read -r BASEDIR
fi

if [ -t 0 ] && [ -z "${uMAMBA_ENVNAME:-}" ]; then
  printf "micromamba environment name? [vvg-box] "
  read -r uMAMBA_ENVNAME
fi

# Fallbacks
export BASEDIR="${BASEDIR:-./vvg-box}"
BINDIR="${BASEDIR}/bin"
export uMAMBA_ENVNAME="${uMAMBA_ENVNAME:-vvg-box}"
uMAMBA_DIR="${BASEDIR}/opt/umamba"

# defaults
PYVER="${PYVER:-3.12}"

mkdir -p "${BINDIR}"

# Computing artifact location
case "$(uname)" in
  Linux)
    PLATFORM="linux" ;;
  Darwin)
    PLATFORM="osx" ;;
  *NT*)
    PLATFORM="win" ;;
esac

ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|ppc64le|arm64)
      ;;  # pass
  *)
    ARCH="64" ;;
esac

case "$PLATFORM-$ARCH" in
  linux-aarch64|linux-ppc64le|linux-64|osx-arm64|osx-64|win-64)
      ;;  # pass
  *)
    echo "Failed to detect your OS" >&2
    exit 1
    ;;
esac

if [ "${VERSION:-}" = "" ]; then
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-${PLATFORM}-${ARCH}"
else
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/download/micromamba-${VERSION}/micromamba-${PLATFORM}-${ARCH}"
fi


# Downloading artifact
echo "Downloading and installing micromamba..."
mkdir -p "${BINDIR}"
if hash curl >/dev/null 2>&1; then
  if [ -n "${CURL_OPTS:-}" ]; then
    eval "curl ${CURL_OPTS} \"${RELEASE_URL}\" -o \"${BINDIR}/micromamba\" -fsSL --compressed"
  else
    curl "${RELEASE_URL}" -o "${BINDIR}/micromamba" -fsSL --compressed
  fi
elif hash wget >/dev/null 2>&1; then
  if [ -n "${WGET_OPTS:-}" ]; then
    eval "wget ${WGET_OPTS} -qO \"${BINDIR}/micromamba\" \"${RELEASE_URL}\""
  else
    wget -qO "${BINDIR}/micromamba" "${RELEASE_URL}"
  fi
else
  echo "Neither curl nor wget was found" >&2
  exit 1
fi
chmod +x "${BINDIR}/micromamba"


# this is specific for vivaxGEN vvg-box utility

echo "Setting up base directory structure at ${BASEDIR}"

export OPT_DIR="${BASEDIR}/opt"
export APPTAINER_DIR="${BASEDIR}/opt/apptainer"
export ENVS_DIR="${BASEDIR}/envs"
export ETC_DIR="${BASEDIR}/etc"
export BASHRC_DIR="${ETC_DIR}/bashrc.d"
export SNAKEMAKEPROFILE_DIR="${ETC_DIR}/snakemake-profiles"

mkdir "${OPT_DIR}"
mkdir "${APPTAINER_DIR}"
mkdir "${ENVS_DIR}"
mkdir "${ETC_DIR}"
mkdir "${BASHRC_DIR}"
mkdir "${SNAKEMAKEPROFILE_DIR}"

echo "vvg-box" >> "${ETC_DIR}"/installed-repo.txt

# save installation environment variables
# other installation scripts can append this file

vars_to_save=(PYVER EXCLUDE INCLUDE OMIT)

# Loop through and save them safely while `set -u` is enabled
for var in "${vars_to_save[@]}"; do
  # Use indirect expansion with a default so unset variables expand to empty
  echo "$var='${!var:-}'" >> "${ETC_DIR}/inst-envvars"
done

# check if we are provided with MAMBA_ROOT_PREFIX
if [[ -z ${MAMBA_ROOT_PREFIX:-} ]]; then
  export MAMBA_ROOT_PREFIX="${uMAMBA_DIR}"
else
  echo "Using provided MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX}"
fi

eval "$("${BINDIR}"/micromamba shell hook -s posix)"

echo "Creating ${uMAMBA_ENVNAME} environment"
micromamba create -n "${uMAMBA_ENVNAME}"

echo "Activating micromamba base environment"
micromamba activate "${uMAMBA_ENVNAME}"

if ! [ -x "$(command -v git)" ]; then
  echo "Installing git"
  micromamba -y install "git>=2.49,<3" -c conda-forge
fi

# install vvg-box repo as early as possible, so that we can use its helper functions in subsequent installation scripts
echo "Cloning vivaxGEN vvg-box repository"
# For dev: add --branch dev
git clone --depth 1 https://github.com/vivaxgen/vvg-box.git "${ENVS_DIR}"/vvg-box
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
