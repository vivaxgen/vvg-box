# install other dependencies with micromamba
micromamba -y install -f ${ENVS_DIR}/vvg-box/etc/inst-scripts/env.yaml

# prepare activation file
echo "Preparing activation source file"
${ENVS_DIR}/vvg-box/bin/generate-activation-script.py

# re-source activation script
echo "Resourcing vvg-box environment"
export VVG_BASEDIR=${BASEDIR}
__IN_VVG_INSTALLATION__=1
source ${VVG_BASEDIR}/etc/bashrc

# all the following run under active vvg-box environment
${VVGBIN}/generate-executable-links.py

# check if we are provided with SPECDIR
if [[ -z ${SPECDIR:-} ]]; then
  echo "Using default packages"
else
  echo "Using specification directory ${SPECDIR} to install packages"
  ${VVGBIN}/install-from-specdir.py
fi

echo "Detecting job/batch scheduler"
${ENVS_DIR}/vvg-box/bin/set-snakemake-profile.py

# EOF
