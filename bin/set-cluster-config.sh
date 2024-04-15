#!/usr/bin/env bash

# check VVG_BASEDIR

if [[ -z ${VVG_BASEDIR:-} ]]; then
    echo "ERR: environment variable VVG_BASEDIR is not set!"
    exit 1
fi

BASHRC_DIR=${VVG_BASEDIR}/etc/bashrc.d
SNAKEMAKEPROFILE_DIR=${VVG_BASEDIR}/envs/vvg-base/etc/snakemake-profiles

if [ -x "$(command -v sbatch)" ] && [ -x "$(command -v sacct)" ]; then
  echo "Setting up for SLURM"
  ln -sr ${SNAKEMAKEPROFILE_DIR}/slurm/99-snakemake-profile ${BASHRC_DIR}/
elif [ -x "$(command -v qsub)" ] && [ -x "$(command -v qstat)" ]; then
  echo "Setting up for PBS/Torque"
  ln -sr ${SNAKEMAKEPROFILE_DIR}/slurm/99-snakemake-profile ${BASHRC_DIR}/
else
  echo "No batch/job scheduler found"
fi

# EOF
