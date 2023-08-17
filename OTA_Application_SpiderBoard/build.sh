#!/bin/bash -eu

export PATH=~/.local/bin:$PATH
SCRIPT_DIR=$(cd `dirname $0` && pwd)

AOS_VERSION="v1.0.0"

# Prepare working directory
cd ${SCRIPT_DIR}
cd ./work

# Prepare additional repo
mkdir -p ./yocto
git clone https://github.com/aoscloud/meta-aos-rcar-gen4 \
    ./yocto/meta-aos-rcar-gen4
cd ./yocto/meta-aos-rcar-gen4
git checkout ${AOS_VERSION}
cd ../../

# Apply patch
cd ./yocto/meta-aos-rcar-gen4
git am ../../../patchset_aos/*
cd ../../

# Apply ref app plugin for aos update manager
rm -rf ./yocto/meta-aos-rcar-gen4/meta-aos-rcar-gen4-domd/recipes-aos/aos-updatemanager
cp ./../aos_local_patch/updatemanager ./yocto/meta-aos-rcar-gen4/meta-aos-rcar-gen4-domd/recipes-aos

# Apply patch for aos-update
rm -rf ./yocto/meta-aos-rcar-gen4/meta-aos-rcar-gen4-dom0/recipes-core/aos-update
cp ./../aos_local_patch/update ./yocto/meta-aos-rcar-gen4/meta-aos-rcar-gen4-dom0/recipes-core

#############################################
# END: Apply patch for meta-aos-rcar-gen4   #
#############################################

moulin ./aos-rcar-gen4.yaml --BUILD_DOMD_SDK no
ninja
ninja image-full
gzip full.img
if [[ -e "${SCRIPT_DIR}/work/yocto/build-domd/tmp/deploy/sdk" ]]; then
    find ${SCRIPT_DIR}/work/yocto/build-domd/tmp/deploy/sdk/ -name *.sh | xargs cp -f -t ${SCRIPT_DIR}/work/
fi
echo "Build finished !"
