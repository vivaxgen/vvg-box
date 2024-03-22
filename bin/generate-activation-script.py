#!/usr/bin/env python3

# this script requires BASEDIR and uMAMBA_ENVNAME environment to be set

import pathlib
import os
import argparse

p = argparse.ArgumentParser()
p.add_argument('-o', '--outfile', default='',
               help='activation file pathname')
p.add_argument('-n', '--envname', default='',
               help='micromamba environment name')
p.add_argument('-b', '--basedir', default='',
               help='vvg base directory')
p.add_argument('-e', '--extraline', action='append', default=[],
               help='extra lines to insert as statements')

args = p.parse_args()


BASEDIR = (
    pathlib.Path(args.basedir).resolve() if args.basedir else
    pathlib.Path(os.environ['BASEDIR']).resolve()
)
uMAMBA_ENVNAME = args.envname or os.environ['uMAMBA_ENVNAME']

activation_file = (pathlib.Path(args.outfile) if args.outfile
                   else BASEDIR / 'bin' / 'activate')

activation_content = f"""#!/usr/bin/env bash

# the directory below must be hard-coded since we cannot assume that
# GNU coreutils (which provides readlink and dirname commands) is already
# installed
VVG_BASEDIR={BASEDIR.as_posix()}
BASHRC=${{VVG_BASEDIR}}/etc/bashrc
uMAMBA_ENVNAME={uMAMBA_ENVNAME}

if [[ "${{BASH_SOURCE[0]}}" == "${{0}}" ]]; then
  set -o errexit
  set -o pipefail
  set -o nounset

  bash --init-file <(echo "
    . /etc/profile;
    . ~/.bashrc;
    export VVG_BASEDIR=${{VVG_BASEDIR}};
    export uMAMBA_ENVNAME=${{uMAMBA_ENVNAME}};
    {';'.join(args.extraline)};
    . ${{BASHRC}}
    "
  )

else

  {';'.join(args.extraline)};
 q . ${{BASHRC}}

fi

"""

with open(activation_file, "w") as out:
    out.write(activation_content)

activation_file.chmod(0o775)

print(f"Activation file is successfully written as {activation_file.as_posix()}")

# EOF
