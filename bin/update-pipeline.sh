#!/usr/bin/env bash

# if VVG_PULL_WITHOUT_TAG is set, then all pulls are not using tag

echo "Updating all repositories under $VVG_BASEDIR/envs..."
for p in $VVG_BASEDIR/envs/*; do
    if [ -d "$p" ]; then
        echo "Updating ${p}"
        (
            cd "$p";
            if [ -z "${VVG_PULL_WITHOUT_TAG+x}" ] && [ -f ".git-pull-tag" ]; then
                tag=$(<.git-pull-tag)
                echo "Pulling from main ${tag}"
                git pull origin "${tag}";
            else
                echo "Pulling from main"
                git pull;
            fi
        )
    fi
done
unset p

echo "Updating finished."

