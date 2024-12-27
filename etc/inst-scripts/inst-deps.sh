
# install Mamba to complement Micromamba since Snakemake currently can not directly
# handle Micromamba
echo "Installing Mamba"
retry 5 micromamba -y install mamba -c conda-forge -c defaults

PYVER=${PYVER:-3.12}
echo "Installing base python ${PYVER}"
retry 5 micromamba -y install python=${PYVER} -c conda-forge -c defaults

echo "Installing Snakemake"
retry 5 pip3 install "snakemake<9" snakemake-executor-plugin-cluster-generic

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
