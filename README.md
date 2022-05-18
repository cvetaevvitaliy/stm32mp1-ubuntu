# Ubuntu 18.04, 20.04, 22.04 Debian 10, 11 for stm32mp1
This repo for build Ubuntu/Debian on stm32mp1xx CPU <br> 
Availability
Boards:

  * [EV-STM32MP157-SODIMM](http://otladka.com.ua/index.php?option=com_virtuemart&page=shop.product_details&flypage=vmj_naru.tpl&category_id=41&product_id=284&Itemid=71)
  * [Discovery kit with STM32MP157D MPU 88 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157D-DK1/13536964)
  * [Discovery kit with STM32MP157F MPU 47 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157F-DK2/13536968)
  * [Evaluation board with STM32MP157D MPU 43 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157D-EV1/13536967)
  * [Evaluation board with STM32MP157F MPU 32 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157F-EV1/12395904)

## Basic Requirements
Running a recent supported release of Debian, Fedora or Ubuntu on a x86 64bit based PC; without OS Virtualization Software. <br>
Many of the listed commands assume `/bin/bash` as the default shell. <br> 

ARM Cross Compiler – GCC: <br>
  * ARM Linux GCC Toolchain Binaries: https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/ <br>

Bootloader <br>
  * Das U-Boot – the Universal Boot Loader: http://www.denx.de/wiki/U-Boot <br>
  * Source: https://github.com/STMicroelectronics/u-boot  <br>

ATF <br>
  * arm trusted firmware - https://trustedfirmware-a.readthedocs.io/en/latest/
  * Source: https://github.com/STMicroelectronics/arm-trusted-firmware 

Linux Kernel <br>
  * ST Mainline tree: https://github.com/STMicroelectronics/linux <br>

ARM based rootfs <br>
  * Debian: https://www.debian.org <br>
  * Ubuntu: https://www.ubuntu.com  <br>

# Automatic build 
For full automatic build run:
```bash
./build.sh 
```
*NOTE: Default build Ubuntu 22.04 Choosing a distribution to build in development.* <br>
*New contributors are welcome in development!*

For separate build, uboot, kernel and rootfs
```bash
./build-uboot.sh
./build-linux.sh
```
For make sdcard.img image
```bash
./rootfs.sh         # for get base rootfs sceleton
./create-rootfs.sh  # make sd card image
```

***update in progress build scripts**


# Manual build 
For manual build, follow these steps.

# Depends

```
sudo apt install flex bison ncurses-base build-essential qemu-user-static device-tree-compiler
```

## ARM Cross Compiler: GCC
This is a pre-built (64bit) version of GCC that runs on generic linux, sorry (32bit) x86 users, it’s time to upgrade…
Download/Extract:

```bash
#user@localhost:~$
wget -c https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/10.3.0/x86_64-gcc-10.3.0-nolibc-arm-linux-gnueabi.tar.gz
tar xf x86_64-gcc-10.3.0-nolibc-arm-linux-gnueabi.tar.gz
export CC=`pwd`/gcc-10.3.0-nolibc/arm-linux-gnueabi/bin/arm-linux-gnueabi-
```

Test Cross Compiler:

```bash
#user@localhost:~$
${CC}gcc --version
```

```bash
#Test Output:
arm-linux-gnueabi-gcc (GCC) 10.3.0
Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```


## Bootloader: U-Boot

Das U-Boot – the Universal Boot Loader: http://www.denx.de/wiki/U-Boot  <br>
Depending on your Linux Distrubution, you will also need a host gcc and other tools, so with Debian/Ubuntu start with installing the build-essential meta package.  <br>
Download:  <br>

```bash
#user@localhost:~$
git clone -b v2020.10-stm32mp https://github.com/STMicroelectronics/u-boot
cd u-boot
```

Configure and Build: <br>

**stm32mp157a-sodimm2-mx**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157a-sodimm2-mx all
```

**stm32mp157c-ev1**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-ev1 all
```

**stm32mp157c-ed1**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-ed1 all
```

**stm32mp157a-dk1**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157a-dk1 all
```

**stm32mp157c-dk2**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-dk2 all
```

# arm-trusted-firmware

```bash
git clone -b v2.4-stm32mp https://github.com/STMicroelectronics/arm-trusted-firmware
cd arm-trusted-firmware
```

**stm32mp157a-sodimm2-mx**
```bash
make CROSS_COMPILE=${CC} \
			PLAT=stm32mp1 \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      STM32MP_SDMMC=1 \
      STM32MP_EMMC=1 \
      AARCH32_SP=sp_min \
      DTB_FILE_NAME=stm32mp157a-sodimm2-mx.dtb \
      BL33_CFG=../u-boot/u-boot.dtb \
      BL33=../u-boot/u-boot-nodtb.bin \
      all fip
```

**stm32mp157c-ev1**
```bash
make CROSS_COMPILE=${CC} \
			PLAT=stm32mp1 \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      STM32MP_SDMMC=1 \
      STM32MP_EMMC=1 \
      AARCH32_SP=sp_min \
      DTB_FILE_NAME=stm32mp157c-ev1.dtb \
      BL33_CFG=../u-boot/u-boot.dtb \
      BL33=../u-boot/u-boot-nodtb.bin \
      all fip
```

**stm32mp157c-ed1**
```bash
make CROSS_COMPILE=${CC} \
			PLAT=stm32mp1 \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      STM32MP_SDMMC=1 \
      STM32MP_EMMC=1 \
      AARCH32_SP=sp_min \
      DTB_FILE_NAME=stm32mp157c-ed1.dtb \
      BL33_CFG=../u-boot/u-boot.dtb \
      BL33=../u-boot/u-boot-nodtb.bin \
      all fip
```

**stm32mp157a-dk1**
```bash
make CROSS_COMPILE=${CC} \
			PLAT=stm32mp1 \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      STM32MP_SDMMC=1 \
      STM32MP_EMMC=1 \
      AARCH32_SP=sp_min \
      DTB_FILE_NAME=stm32mp157a-dk1.dtb \
      BL33_CFG=../u-boot/u-boot.dtb \
      BL33=../u-boot/u-boot-nodtb.bin \
      all fip
```

**stm32mp157c-dk2**
```bash
make CROSS_COMPILE=${CC} \
			PLAT=stm32mp1 \
      ARCH=aarch32 \
      ARM_ARCH_MAJOR=7 \
      STM32MP_SDMMC=1 \
      STM32MP_EMMC=1 \
      AARCH32_SP=sp_min \
      DTB_FILE_NAME=stm32mp157c-dk2.dtb \
      BL33_CFG=../u-boot/u-boot.dtb \
      BL33=../u-boot/u-boot-nodtb.bin \
      all fip
```


## Linux Kernel
This script will build the kernel, modules, device tree binaries and copy them to the deploy directory.

Download:
```bash
#user@localhost:~$
git clone -b v5.10-stm32mp https://github.com/STMicroelectronics/linux
cd linux
```


**Build:**
```bash
# ST defconfig 
make ARCH=arm CROSS_COMPILE=${CC} multi_v7_defconfig fragment-01-multiv7_cleanup.config fragment-02-multiv7_addons.config

# Choose the kernel modules you need
make ARCH=arm CROSS_COMPILE=${CC} menuconfig
make ARCH=arm CROSS_COMPILE=${CC} zImage modules -j16

# build dts
make ARCH=arm CROSS_COMPILE=${CC} dtbs

# install kernel modules to pach
mkdir -p ../deploy
cp -v arch/arm/boot/zImage ../deploy
mkdir -p ../deploy/modules
make ARCH=arm CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="../deploy/modules"

# install dtsb files to pach
mkdir -p ../deploy/dtsb
make ARCH=arm CROSS_COMPILE=${CC} dtbs_install INSTALL_DTBS_PATH=../deploy/dtsb

# export kernel version 
export kernel_ver=$(cat "include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )
echo ${kernel_ver}
cd ..
```

## Root File System

**Debian 11**

**User and password:** `debian  temppwd` `root  root` <br>

Download:
```bash
#user@localhost:~$
wget -c https://rcn-ee.com/rootfs/eewiki/minfs/debian-11.1-minimal-armhf-2021-11-02.tar.xz
```

Extract:
```bash
#user@localhost:~$
tar xf debian-11.1-minimal-armhf-2021-11-02.tar.xz
```


## Ubuntu 20.04 LTS
**User and password:** `ubuntu  temppwd` `root  root` <br>

Download:
```bash
#user@localhost:~$
wget -c https://rcn-ee.com/rootfs/eewiki/minfs/ubuntu-20.04.3-minimal-armhf-2021-11-02.tar.xz
```

Extract:
```bash
#user@localhost:~$
tar xf ubuntu-20.04.3-minimal-armhf-2021-11-02.tar.xz
```

## Ubuntu 18.04 LTS
**User and password:** `ubuntu  temppwd` `root  root` <br>

Download:
```bash
#user@localhost:~$
wget -c https://rcn-ee.com/rootfs/eewiki/minfs/ubuntu-18.04.6-minimal-armhf-2021-11-02.tar.xz
```

Extract:
```bash
#user@localhost:~$
tar xf ubuntu-18.04.6-minimal-armhf-2021-11-02.tar.xz
```

Setup image for flash to microSD card

**Create image:**
```bash
sudo dd if=/dev/zero of=~/sdcard.img bs=4096M count=2
export DISK=~/sdcard.img
```

check output dd:
```bash
# check output:
# 0+2 records in
# 0+2 records out
# 4294959104 bytes (4,3 GB, 4,0 GiB) copied, 13,5095 s, 318 MB/s
```


**Create Partition Layout:**
```bash
export IMAGE_FILENAME="sdcard-stm32mp157.img"
dd if=/dev/zero of=${DIR}/deploy/${IMAGE_FILENAME} bs=4096M count=2

sgdisk --resize-table=128 -a 1 \
            -n 1:34:545    -c 1:fsbl1   \
            -n 2:546:1057  -c 2:fsbl2   \
            -n 3:1058:5153 -c 3:fip    \
            -n 4:5154:     -c 4:rootfs  \
            -p ./deploy/${IMAGE_FILENAME}
            
```

check output sgdisk:
```bash
#
# Disk /home/vitaliy/sdcard.img: 8388592 sectors, 4.0 GiB
# Sector size (logical): 512 bytes
# Disk identifier (GUID): 6473AC10-6A3A-4A4B-B3BF-59BD7982185D
# Partition table holds up to 128 entries
# Main partition table begins at sector 2 and ends at sector 33
# First usable sector is 34, last usable sector is 8388558
# Partitions will be aligned on 1-sector boundaries
# Total free space is 0 sectors (0 bytes)

 Number  Start (sector)    End (sector)  Size       Code  Name
   1              34             545   256.0 KiB   8300  fsbl1
   2             546            1057   256.0 KiB   8300  fsbl2
   3            1058            5153   2.0 MiB     8300  ssbl
   4            5154         8388558   4.0 GiB     8300  rootfs
```

**Set legacy BIOS partition:**

```bash
sgdisk -A 4:set:2 ./deploy/${IMAGE_FILENAME}
```

**Create loop device**
```bash
 LOOP_DEVICE=$(sudo losetup --partscan --show --find ./deploy/${IMAGE_FILENAME})
```
Check mounted partition:
```
 ls -l ${LOOP_DEVICE}*
```
```bash
#user@localhost:~$ ls -l /dev/loop0*
brw-rw---- 1 root disk   7,  0 лис  7 13:31 /dev/loop0
brw-rw---- 1 root disk 259,  7 лис  7 13:31 /dev/loop0p1
brw-rw---- 1 root disk 259,  8 лис  7 13:31 /dev/loop0p2
brw-rw---- 1 root disk 259,  9 лис  7 13:31 /dev/loop0p3
brw-rw---- 1 root disk 259, 10 лис  7 13:31 /dev/loop0p4
```

**Install U-Boot bootloader:**

**stm32mp157a-sodimm2-mx**
```bash
#user@localhost:~$
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157a-sodimm2-mx.stm32 of=${LOOP_DEVICE}p1
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157a-sodimm2-mx.stm32 of=${LOOP_DEVICE}p2
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/fip.bin of=${LOOP_DEVICE}p3
```

**stm32mp157c-ev1**
```bash
#user@localhost:~$
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157c-ev1.stm32 of=${LOOP_DEVICE}p1
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157c-ev1.stm32 of=${LOOP_DEVICE}p2
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/fip.bin of=${LOOP_DEVICE}p3
```

**stm32mp157c-ed1**
```bash
#user@localhost:~$
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157c-ed1.stm32 of=${LOOP_DEVICE}p1
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157c-ed1.stm32 of=${LOOP_DEVICE}p2
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/fip.bin of=${LOOP_DEVICE}p3
```

**stm32mp157a-dk1**
```bash
#user@localhost:~$
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157a-dk1.stm32 of=${LOOP_DEVICE}p1
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157a-dk1.stm32 of=${LOOP_DEVICE}p2
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/fip.bin of=${LOOP_DEVICE}p3
```

**stm32mp157c-dk2**
```bash
#user@localhost:~$
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157c-dk2.stm32 of=${LOOP_DEVICE}p1
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/tf-a-stm32mp157c-dk2.stm32 of=${LOOP_DEVICE}p2
sudo dd if=./arm-trusted-firmware/build/stm32mp1/release/fip.bin of=${LOOP_DEVICE}p3
```



**Format RootFS Partition:**
```bash
sudo mkfs.ext4 -L rootfs ${LOOP_DEVICE}p4
```

**Mount rootfs file system**
```bash
sudo mkdir -p deploy/rootfs
MOUNT_PATH=deploy/rootfs
sudo mount ${LOOP_DEVICE}p4 ${MOUNT_PATH}
```

## Install Kernel and Root File System

**Copy Root File System**
```bash
#Debian; Root File System: user@localhost:~$
sudo tar xfvp ./debian-*-*-armhf-rootfs-*.tar -C ${MOUNT_PATH}
sync
```

```bash
#Ubuntu; Root File System: user@localhost:~$
sudo tar xfvp ./ubuntu-base-XX.XX-base-armhf.tar.gz -C ${MOUNT_PATH}
sync
```

**Setup extlinux.conf**
```bash
#user@localhost:~$
sudo mkdir -p ${MOUNT_PATH}/boot/extlinux/
sudo sh -c "echo 'label Linux ${kernel_ver}' > ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
sudo sh -c "echo '    kernel /boot/vmlinuz-${kernel_ver}' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
sudo sh -c "echo '    append console=ttySTM0,115200 console=tty1,115200 root=/dev/mmcblk\${boot_instance}p4 ro rootwait ' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
sudo sh -c "echo '    fdtdir /boot/dtbs/${kernel_ver}/' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
```

**Copy Kernel Image**
```bash
#user@localhost:~$
sudo cp -v ./deploy/${kernel_ver}.zImage ${MOUNT_PATH}/boot/vmlinuz-${kernel_ver}
```

**Copy Kernel Device Tree Binaries**
```bash
#user@localhost:~$
sudo mkdir -p ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
sudo cp -r ./deploy/dtsb/* ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
```

**Copy Kernel Modules**
```bash
#user@localhost:~$
sudo cp -r ./deploy/modules/. ${MOUNT_PATH}/usr/
```

**File Systems Table (/etc/fstab)**
```bash
#user@localhost:~/$
sudo sh -c "echo '/dev/mmcblk0p4  /  auto  errors=remount-ro  0  1' >> /mnt/rootfs/etc/fstab"
```

**For DK2 board. WiFi bin and config files**
```bash
#user@localhost:~/$
mkdir wifi
wget -P wifi https://github.com/cvetaevvitaliy/stm32mp1-ubuntu/raw/master/wifi_firmware/cyfmac43430-sdio.bin
wget -P wifi https://github.com/cvetaevvitaliy/stm32mp1-ubuntu/raw/master/wifi_firmware/cyfmac43430-sdio.1DX.clm_blob
wget -P wifi https://github.com/cvetaevvitaliy/stm32mp1-ubuntu/raw/master/wifi_firmware/brcmfmac43430-sdio.txt

sudo mkdir -p ${MOUNT_PATH}/lib/firmware/brcm/
sudo cp -v ./wifi/brcmfmac43430-sdio.txt ${MOUNT_PATH}/lib/firmware/brcm/brcmfmac43430-sdio.st,stm32mp157c-dk2.txt
sudo cp -v ./wifi/cyfmac43430-sdio.bin ${MOUNT_PATH}/lib/firmware/brcm/brcmfmac43430-sdio.bin
sudo cp -v ./wifi/cyfmac43430-sdio.1DX.clm_blob ${MOUNT_PATH}/lib/firmware/brcm/brcmfmac43430-sdio.clm_blob

```

**Finish:**
```bash
sync
sudo umount ${MOUNT_PATH}
sudo losetup -D
```

After successfully completing these steps, you will get `.img` image for writing to SD card

## How to flash .img to SD card

For safe and easy writing to SD card download [balenaEtcher](https://www.balena.io/etcher/)

**Steps:**
  * Insert SD card to card reader 
  * Openn balenaEtcher
  * Select `sdcard.img`
  * Select connected SD card
  * Push button FLash
  * Done
 
After flash remove sd card from PC and insert to STM32MP157 board

## Finished image for flash SD card for STM32MP157-DK2

If you do not want to go through all the steps, you can download the finished SD card image, just write it to the SD card

*update in progress

