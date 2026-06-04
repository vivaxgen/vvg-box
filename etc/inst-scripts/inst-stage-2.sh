# stage-2

# check if we are running in a pixi-based vvg-box session by checking
# the absence of PIXI_ENVNAME variable, if not, print a warning and exit with an error code
# if we are not, then print a warning and exit with an error code
if [[ -z ${PIXI_ENVNAME} ]]; then
  echo -ne "\e[31m"
  echo "ATTENTION: this session is not a pixi-based vvg-box session"
  echo "ATTENTION: Please reinstall completely with the latest release!"
  echo -e "\e[0m"
  exit 1
fi

# re-source activation script as early as possible to get access to
# all necessary environment variables and functions
echo -e "\e[32m>>> Re-sourcing vvg-box environment\e[0m"
__IN_VVG_INSTALLATION__=1
source ${VVG_BASEDIR}/etc/bashrc
${VVGBIN}/link-resource-files.sh ${ENVS_DIR}/vvg-box/etc/bashrc.d
reload_vvg_profiles

INST_SCRIPTS_DIR="${VVG_REPODIR}/etc/inst-scripts"

echo -e "\e[32m>>> Checking and installing core dependencies\e[0m"
source ${INST_SCRIPTS_DIR}/inst-deps-core.sh

# if VVG_MANIFEST_FILE is not set or not defined, source the inst-deps.sh,
# otherwise, extract the MANIFEST_FILE at VVG_BASEDIR/opt/pixi to properly
# have all .toml files in place
if [[ -z ${VVG_MANIFEST_FILE:-} ]]; then
  echo -e "\e[32m>>> No manifest file provided, installing dependencies with inst-deps.sh\e[0m"
  source ${INST_SCRIPTS_DIR}/inst-deps.sh
else
  echo -e "\e[32m>>> Manifest file provided, extracting manifest files\e[0m"
  unzip -o "${VVG_MANIFEST_FILE}" -d "${VVG_BASEDIR}"
  (
    set +u
    cd "${VVG_BASEDIR}"
    cat opt/pixi/global/manifests/pixi-global-additional.toml >> opt/pixi/global/manifests/pixi-global.toml
    echo -e "\e[32m>>> Syncing pixi global environment\e[0m"
    retry 5 pixi global sync
    echo -e "\e[32m>>> Installing pixi workspace dependencies\e[0m"
    retry 5 pixi install
    # or use pixi install --frozed to install exaxtly as pixi.lock
  )
fi

# prepare activation file
echo -e "\e[32m>>> Preparing activation source file\e[0m"
${ENVS_DIR}/vvg-box/bin/generate-activation-script.py

# all the following run under active vvg-box environment
${VVGBIN}/generate-executable-links.py

echo -e "\e[32m>>> Detecting job/batch scheduler\e[0m"
${ENVS_DIR}/vvg-box/bin/set-snakemake-profile.py

# set permission for .toml files to be readable by all users
echo -e "\e[32m>>> Setting permissions for manifest files\e[0m"
fix-manifest-permission

# EOF
