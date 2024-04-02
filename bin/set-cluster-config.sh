#!/usr/bin/env bash

# check VVG_BASEDIR

if [[ -z ${VVG_BASEDIR:-} ]]; then
    echo "ERR: environment variable VVG_BASEDIR is not set!"
    exit 1
fi

BASHRC_DIR=${VVG_BASEDIR}/etc/bashrc.d
SNAKEMAKEPROFILE_DIR=${VVG_BASEDIR}/envs/vvg-base/snakemake-profiles

if [ -x "$(command -v srun)" ] && [ -x "$(command -v scancel)" ]; then
  echo "Setting up for SLURM"
  ln -sr ${SNAKEMAKEPROFILE_DIR}/slurm/99-snakemake-profile ${BASHRC_DIR}/
elif [ -x "$(command -v qrun)" ] && [ -x "$(command -v qdel)" ]; then
  echo "Setting up for PBS/Torque"
  ln -sr ${SNAKEMAKEPROFILE_DIR}/slurm/99-snakemake-profile ${BASHRC_DIR}/
else
  echo "No batch/job scheduler found"
fi

# EOF
