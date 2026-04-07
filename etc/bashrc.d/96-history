#!/usr/bin/env bash

# set history

if [ -n "${uMAMBA_ENVNAME:-}" ] && [ -z "${HIST_EXT:-}" ]; then

    export HISTFILE="${HOME}/.bash_history.${uMAMBA_ENVNAME}"

    export HISTSIZE=20000
    export HISTFILESIZE=20000
    history -c; history -r

fi

# EOF