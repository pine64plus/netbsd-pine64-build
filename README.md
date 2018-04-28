# netbsd-pine64-build
Scripts and tools to build NetBSD for Pine64+ in aarch64 mode

## How to start

    ./build-pine64.sh

or, put the script in path and call it from the the already cloned NetBSD source tree.

The Pine64 image ready to be flashed will be in the NetBSD source tree at:

    obj/releasedir/evbarm/binary/pine64.img

## Writing the image to SD card

    dd if=bj/releasedir/evbarm/binary/pine64.img of=<fill in the device file for the SD card> BS=1M conv=fsync

To find out the appropriate device file, check the tail of dmesg after you connect the SD card, or use blkid. You will need to use the entire block device, not a partition, so expect something like /dev/sdz (as opposed to not /dev/sdz2).
