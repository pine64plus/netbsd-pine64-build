#!/bin/sh

set -e

if [ "$(uname -s)" = "Linux" ]; then
	J_PAR="-j $(nproc)"
else
	J_PAR=""
	echo 'This script was only tested on Linux and COULD BREAK SEVERELY ON OTHER OPERATING SYSTEMS! Press Ctrl+C to abort, or Enter to proceed.'
	read
fi

# check if NetBSD's build.sh exists or clone netbsd and cd to src
if [ ! -x build.sh ] || ! grep -m 1 -n 'NetBSD: build.sh' build.sh | grep -q '^2:#' ; then
	NB_GIT_URL='https://github.com/NetBSD/src.git'
	git clone --depth 1 $NB_GIT_URL src && cd src
fi

NB_SRC_DIR=$(pwd)


T_ARCH=aarch64
T_MACH=evbarm
T_GZIMG=arm64.img.gz
TARGET_IMG=pine64.img

UBOOT_DIR=obj/u-boot-pine64
# fetch u-boot x86_64:u-boot-pine64-2017.11nb2.tgz(NetBSD 8.0):
# from https://ftp.netbsd.org/pub/pkgsrc/current/pkgsrc/sysutils/u-boot-pine64/README.html
URL_UBOOT_PKG='ftp://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/x86_64/8.0_2017Q4/All/u-boot-pine64-2017.11nb2.tgz'
UBOOT_PKG_FN=u-boot-pine64.tar.xz
UBOOT_IMG=u-boot-sunxi-with-spl.bin


# NetBSD tools, build, kernel, modules and image
./build.sh $J_PAR -u -U -m $T_MACH -a $T_ARCH tools
./build.sh $J_PAR -u -U -m $T_MACH -a $T_ARCH build
./build.sh $J_PAR -u -U -m $T_MACH -a $T_ARCH kernel=GENERIC64 modules
./build.sh $J_PAR -u -U -m $T_MACH -a $T_ARCH -V KERNEL_SETS=GENERIC64 release


mkdir -p $UBOOT_DIR && cd $UBOOT_DIR
[ -f $UBOOT_PKG_FN ] || wget $URL_UBOOT_PKG -O $UBOOT_PKG_FN
xzcat $UBOOT_PKG_FN | tar xvf - --strip-components=3 --warning=no-unknown-keyword share/u-boot/pine64/$UBOOT_IMG

# based on the info at https://wiki.netbsd.org/ports/evbarm/allwinner/ the
# arm64.img file should be modified with the u-boot image for the appropriate
# board:
#
#   Download or build armv7.img from NetBSD -current
#   Write the image to disk: dd if=armv7.img of=/dev/rld0d bs=1m conv=sync
#   Install a board-specific U-Boot (2017.07 or later) from pkgsrc to the SD
#   card:
#   dd if=/usr/pkg/share/u-boot/<boardname>/u-boot-sunxi-with-spl.bin of=/dev/rld0d bs=1k seek=8 conv=sync
#

cd $NB_SRC_DIR/obj/releasedir/$T_MACH/binary
gzcat gzimg/$T_GZIMG > $TARGET_IMG

dd if=$NB_SRC_DIR/$UBOOT_DIR/$UBOOT_IMG of=$TARGET_IMG bs=1k seek=8 conv=sync

