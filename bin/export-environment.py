#!/usr/bin/env python3

# this script should be run under active vvg-base environment

import os
import sys
import argparse
import shutil
import subprocess
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--outdir', default='',
               help='directory for writing conda-env.yaml and pip-freeze.txt')

args = p.parse_args()

if not args.outdir:
    try:
        VVG_BASEDIR = Path(os.environ.get('VVG_BASEDIR'))
        VVG_REPODIR = Path(os.environ.get('VVG_REPODIR'))

        outdir = VVG_BASEDIR / 'etc'

    except KeyError:
        print('ERR: without --outdir, this script must be run under active '
              'vvg-base environment')
        sys.exit(101)
else:
    outdir = Path(args.outdir)

print(f"Exporting conda environment to {outdir}/conda-env.yaml")
ret_code = subprocess.call(f'micromamba env export > {outdir}/conda-env.yaml',
                           shell=True)

print(f'Exporting pip environment to {outdir}/pip-freeze.txt')
ret_code = subprocess.call(f'pip3 freeze > {outdir}/pip-freeze.txt',
                           shell=True)

# EOF
