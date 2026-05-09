#!/usr/bin/env python3

# this script should be run under active vvg-box environment

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
        VVG_BASEDIR = Path(os.environ.get('VVG_BASEDIR')) # type: ignore
        VVG_REPODIR = Path(os.environ.get('VVG_REPODIR')) # type: ignore

        outdir = VVG_BASEDIR / 'etc'

    except KeyError:
        print('ERR: without --outdir, this script must be run under active '
              'vvg-box environment')
        sys.exit(101)
else:
    outdir = Path(args.outdir)

PIXI_HOME = Path(os.environ.get('PIXI_HOME')) # type: ignore

print(f"Copying pixi global environment to {outdir}/pixi-global.toml")
shutil.copyfile(PIXI_HOME / "manifests" / "pixi-global.toml", outdir / 'pixi-global.toml')

print(f'Copying pixi workspace environment to {outdir}/pixi-workspace.toml')
shutil.copyfile(os.environ.get("PIXI_PROJECT_MANIFEST"), outdir / 'pixi-workspace.toml')  # type: ignore

# EOF
