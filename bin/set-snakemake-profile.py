#!/usr/bin/env python3

# this script needs to be run under active vvg-base environment

import os
import sys
import argparse
import shutil
from pathlib import Path

try:

    VVG_BASEDIR = os.environ.get('VVG_BASEDIR')

except KeyError:
    print('ERR: this script must be run under active vvg-base environment')
    sys.exit(101)

p = argparse.ArgumentParser()
p.add_argument('--profile-source-file', default='',
               help='profile source file that will be symbolic-linked')

args = p.parse_args()

target = Path(VVG_BASEDIR) / 'etc' / 'bashrc.d' / '99-snakemake-profile'

if args.profile_source_file:
    source_file = Path(args.profile_source_file)
    if not source_file.is_absolute():
        print('ERR: profile source file must be absolute path')
        sys.exit(102)
    if not source_file.exists():
        print('ERR: source file does not exist')
        sys.exit(103)
    target.symlink_to(source_file))
    sys.exit(0)

# testing for SLURM
if shutil.which('sbatch') and shutil.which('sacct'):
    print('INFO: setting up for SLURM')
    target.symlink_to(VVG_ROOTDIR / 'etc' / 'snakemake-profiles' / 'slurm' /
                      '99-snakemake-profile')
    sys.exit(0)

# testing for PBSPro
if shutil.which('qsub') and shutil.which():
    target.symlink_to(VVG_ROOTDIR / 'etc' / 'snakemake-profiles' / 'pbspro' /
                      '99-snakemake-profile')
    sys.exit(0)

# check for custom command
if (SNAKEMAKE_PROFILE_SETTER := os.environ.get('SNAKEMAKE_PROFILE_SETTER', '')):
    import subprocess
    sys.exit(subprocess.run([SNAKEMAKE_PROFILE_SETTER]))

print('No detected workload manager')
sys.exit(0)

