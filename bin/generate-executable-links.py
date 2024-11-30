#!/usr/bin/env python3

# this script requires BASEDIR and uMAMBA_ENVNAME environment to be set

import os
import argparse
from pathlib import Path

# for now, just run os.system

VVGBIN = os.environ['VVGBIN']
VVG_BASEDIR = os.environ['VVG_BASEDIR']
BINDIR = VVG_BASEDIR + '/bin'
VVG_REPODIR = os.environ['VVG_REPODIR']

os.system(f"ln -sr {VVG_REPODIR}/bin/exec {BINDIR}/bin/exec")
os.system(f"ln -sr {BINDIR}/activate {BINDIR}/shell")

# EOF
