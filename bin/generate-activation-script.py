#!/usr/bin/env python3

# this script requires BASEDIR and uMAMBA_ENVNAME environment to be set

import os
import argparse
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('-o', '--outfile', default='',
               help='activation file pathname')
p.add_argument('-n', '--envname', default='',
               help='micromamba environment name')
p.add_argument('-b', '--basedir', default='',
               help='vvg base directory')
p.add_argument('-r', '--mamba-root', default='',
               help='micromamba root directory prefix')
p.add_argument('-e', '--extraenv', action='append', default=[],
               help='extra environment variable to be exported')
p.add_argument('-l', '--extraline', action='append', default=[],
               help='extra lines to insert as statements')


args = p.parse_args()


BASEDIR = (
    Path(args.basedir).resolve() if args.basedir else
    Path(os.environ['BASEDIR']).resolve()
)
MAMBA_ROOT_PREFIX = (
    Path(args.mamba_root).resolve() if args.mamba_root else (
        Path(pfx).resolve() if (pfx := os.environ.get('MAMBA_ROOT_PREFIX', '')) else
        BASEDIR / 'opt' / 'umamba'
    )
)
uMAMBA_ENVNAME = args.envname or os.environ['uMAMBA_ENVNAME']

activation_file = (Path(args.outfile) if args.outfile
                   else BASEDIR / 'bin' / 'activate')

# get extra environemnts
for extra_env in args.extraenv:
    env_name = extra_env.split('=', 1)[0]
    args.extraline.append(
        f'export {env_name}=${{{env_name}}}'
    )

activation_content = f"""#!/usr/bin/env bash

# the directory below must be hard-coded since we cannot assume that
# GNU coreutils (which provides readlink and dirname commands) is already
# installed
VVG_BASEDIR={BASEDIR.as_posix()}
BASHRC=${{VVG_BASEDIR}}/etc/bashrc
MAMBA_ROOT_PREFIX={MAMBA_ROOT_PREFIX.as_posix()}
uMAMBA_ENVNAME={uMAMBA_ENVNAME}

{'\n'.join(args.extraenv)}

if [[ "${{BASH_SOURCE[0]}}" == "${{0}}" ]]; then
  set -euo pipefail

  bash --init-file <(echo "
    . /etc/profile;
    . ~/.bashrc;
    export VVG_BASEDIR=${{VVG_BASEDIR}};
    export uMAMBA_ENVNAME=${{uMAMBA_ENVNAME}};
    export MAMBA_ROOT_PREFIX=${{MAMBA_ROOT_PREFIX}};
    {';'.join(args.extraline)}
    . ${{BASHRC}}
    "
  )

else

  # need to export MAMBA_ROOT_PREFIX since it will still be needed after
  # sourcing
  export MAMBA_ROOT_PREFIX=${{MAMBA_ROOT_PREFIX}}

  {';'.join(args.extraline)}

  . ${{BASHRC}}

fi

"""

with open(activation_file, "w") as out:
    out.write(activation_content)

activation_file.chmod(0o775)

print(f"Activation file is successfully written as {activation_file.as_posix()}")

# EOF
