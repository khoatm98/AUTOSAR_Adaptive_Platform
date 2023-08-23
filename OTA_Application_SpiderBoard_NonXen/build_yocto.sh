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
git checkout -b tmp 74b22db6879b388d700f61e08cb3f239cf940d18
cd $WORK/meta-openembedded
git checkout -b tmp 814eec96c2a29172da57a425a3609f8b6fcc6afe
cd $WORK/meta-renesas
git checkout -b tmp c73719354acc0dee159239a7492aa7b9052d3063
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

echo "The build directory is $(pwd) "


bitbake-layers add-layer meta-aos
bitbake-layers add-layer meta-arm
bitbake-layers add-layer meta-arm-toolchain
bitbake-layers add-layer meta-filesystems
bitbake-layers add-layer meta-perl
bitbake-layers add-layer meta-security
bitbake-layers add-layer meta-selinux
bitbake-layers add-layer meta-virtualization


if [ $2 = "bsp" ]; then
	echo "Run command: #bitbake rcar-image-minimal"
	bitbake rcar-image-minimal
elif [ $2 = "gateway" ]; then
	echo "Run command: #bitbake rcar-image-gateway"
	bitbake rcar-image-gateway
fi
}

build_function $BOARD $OPTION
