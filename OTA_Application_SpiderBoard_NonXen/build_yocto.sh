#!/bin/bash

WORK=`pwd`

cd ./work
WORK=`pwd`
echo $WORK

git clone https://git.yoctoproject.org/poky
git clone https://git.openembedded.org/meta-openembedded
git clone https://github.com/renesas-rcar/meta-renesas.git
git clone https://github.com/aoscloud/meta-aos.git


cd $WORK/poky
git checkout -q "232b553"
cd $WORK/meta-openembedded
git checkout -q "814eec9"
cd $WORK/meta-renesas
git checkout -q "fb473de"
cd $WORK/meta-aos
git checkout -q "v6.0.2"

case "$1" in
"spider")
	echo "Use build configuration for $1 board"
	;;
*)
	echo "Provide board name. Supported boards: spider."
	exit -1
	;;
esac

case "$2" in
"bsp" | "gateway")
	echo "Use build option $2 for $1 board"
	;;
*)
	echo "Provide build option. Supported option: bsp, gateway."
	exit -1
	;;
esac

BOARD=$1
OPTION=$2

build_function () {
cd $WORK

source $WORK/poky/oe-init-build-env build-$1-$2

cp $WORK/meta-renesas/meta-rcar-gateway/docs/sample/conf/$1/poky-gcc/bsp/*.conf conf/
echo 'SSTATE_DIR = "${TOPDIR}/../common_data/sstate"' >> conf/local.conf
echo 'DL_DIR = "${TOPDIR}/../common_data/downloads"' >> conf/local.conf
echo 'INIT_MANAGER = "systemd"' >> conf/local.conf
echo 'DISTRO_FEATURES:append = " virtualization seccomp"' >> conf/local.conf
echo 'IMAGE_INSTALL:append = " aos-iamanager aos-provfirewall aos-communicationmanager aos-updatemanager"' >> conf/local.conf


echo "The build directory is $(pwd) "


bitbake-layers add-layer ../meta-aos
bitbake-layers add-layer ../meta-openembedded/meta-perl
bitbake-layers add-layer ../meta-openembedded/meta-filesystems
bitbake-layers add-layer ../meta-virtualization
bitbake-layers add-layer ../meta-security

if [ $2 = "bsp" ]; then
    echo "Run command: #bitbake rcar-image-minimal"
    bitbake rcar-image-minimal
elif [ $2 = "gateway" ]; then
    echo "Run command: #bitbake rcar-image-gateway"
    bitbake rcar-image-gateway
fi
}

build_function $BOARD $OPTION

