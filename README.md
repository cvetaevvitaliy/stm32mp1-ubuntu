# Ubuntu 18.04, 20.04 for stm32mp157
This repo for build and run Ubuntu on stm32mp157 <br> 
Availability
Boards:

  * [Discovery kit with STM32MP157D MPU 88 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157D-DK1/13536964)
  * [Discovery kit with STM32MP157F MPU 47 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157F-DK2/13536968)
  * [Evaluation board with STM32MP157D MPU 43 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157D-EV1/13536967)
  * [Evaluation board with STM32MP157F MPU 32 at Digi-Key](https://www.digikey.com/en/products/detail/stmicroelectronics/STM32MP157F-EV1/12395904)

## Basic Requirements
Running a recent supported release of Debian, Fedora or Ubuntu on a x86 64bit based PC; without OS Virtualization Software. <br>
Many of the listed commands assume `/bin/bash` as the default shell. <br> 

ARM Cross Compiler – Linaro: https://www.linaro.org <br>
  * Linaro Toolchain Binaries: https://www.linaro.org/downloads/ <br>

Bootloader <br>
  * Das U-Boot – the Universal Boot Loader: http://www.denx.de/wiki/U-Boot <br>
  * Source: https://github.com/u-boot/u-boot/  <br>

Linux Kernel <br>
  * Linus’s Mainline tree: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git <br>

ARM based rootfs <br>
  * Debian: https://www.debian.org <br>
  * Ubuntu: https://www.ubuntu.com  <br>

# Manual build 
For full automatic build run:
```bash
./build.sh 
```

For separate build, uboot, kernel and rootfs
```bash
./build.sh uboot
./build.sh kernel
./build.sh ubuntu
./build.sh debian
```
For make sdcard.img image
```bash
./build.sh mkimage
```

*update in progress build scripts


# Manual build 
For manual build, follow these steps.

## ARM Cross Compiler: GCC
This is a pre-built (64bit) version of GCC that runs on generic linux, sorry (32bit) x86 users, it’s time to upgrade…
Download/Extract:

```bash
#user@localhost:~$
wget -c https://releases.linaro.org/components/toolchain/binaries/6.5-2018.12/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
tar xf gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
export CC=`pwd`/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
```

Test Cross Compiler:

```bash
#user@localhost:~$
${CC}gcc --version
```

```bash
#Test Output:
arm-linux-gnueabihf-gcc (Linaro GCC 6.5-2018.12) 6.5.0
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```


## Bootloader: U-Boot

Das U-Boot – the Universal Boot Loader: http://www.denx.de/wiki/U-Boot  <br>
Depending on your Linux Distrubution, you will also need a host gcc and other tools, so with Debian/Ubuntu start with installing the build-essential meta package.  <br>
Download:  <br>

```bash
#user@localhost:~$
git clone -b v2021.10 https://github.com/u-boot/u-boot --depth=1
cd u-boot/
```

Configure and Build: <br>

**stm32mp157c-ev1**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-ev1 all
```

**stm32mp157c-ed1**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-ed1 all
```

**stm32mp157a-dk1**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157a-dk1 all
```

**stm32mp157c-dk2**
```bash
#user@localhost:~/u-boot$
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig
make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-dk2 all
```


## Linux Kernel
This script will build the kernel, modules, device tree binaries and copy them to the deploy directory.

Download:
```bash
#user@localhost:~$
git clone https://github.com/RobertCNelson/armv7-lpae-multiplatform
cd armv7-lpae-multiplatform/
```

**For v5.10.x (Longterm 5.10.x):**
```bash
#user@localhost:~/armv7-lpae-multiplatform$
git checkout origin/v5.10.x -b tmp
```

**For v5.15.x (Longterm 5.15.x):**
```bash
#user@localhost:~/armv7-lpae-multiplatform$
git checkout origin/v5.15.x -b tmp
```

**Build:**
```bash
#user@localhost:~/armv7-lpae-multiplatform$
./build_kernel.sh
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
sudo sgdisk --resize-table=128 -a 1 \
        -n 1:34:545    -c 1:fsbl1   \
        -n 2:546:1057  -c 2:fsbl2   \
        -n 3:1058:5153 -c 3:ssbl    \
        -n 4:5154:     -c 4:rootfs  \
        -p ${DISK}
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
sudo sgdisk -A 4:set:2 ${DISK}
```

**Create loop device**
```bash
sudo losetup --partscan --show --find ${DISK}
```
Check mounted partition:
```
ls -l /dev/loop0*
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
```bash
#user@localhost:~$
sudo dd if=./u-boot/u-boot-spl.stm32 of=/dev/loop0p1
sudo dd if=./u-boot/u-boot-spl.stm32 of=/dev/loop0p2
sudo dd if=./u-boot/u-boot.img of=/dev/loop0p3
```

**Format RootFS Partition:**
```bash
sudo mkfs.ext4 -L rootfs /dev/loop0p4
```

**Mount rootfs file system**
```bash
sudo mkdir -p /mnt/rootfs
sudo mount /dev/loop0p4 /media/rootfs/
```

## Install Kernel and Root File System
To help new users, since the kernel version can change on a daily basis. The kernel building scripts listed on this page will now give you a hint of what kernel version was built.
```bash
-----------------------------
Script Complete
eewiki.net: [user@localhost:~$ export kernel_version=5.X.Y-Z]
-----------------------------
```

Copy and paste that “export kernel_version=5.X.Y-Z” exactly as shown in your own build/desktop environment and hit enter to create an environment variable to be used later.

```bash
export kernel_version=5.X.Y-Z
```

**Copy Root File System**
```bash
#Debian; Root File System: user@localhost:~$
sudo tar xfvp ./debian-*-*-armhf-*/armhf-rootfs-*.tar -C /mnt/rootfs/
sync
```

```bash
#Ubuntu; Root File System: user@localhost:~$
sudo tar xfvp ./ubuntu-*-*-armhf-*/armhf-rootfs-*.tar -C /mnt/rootfs/
sync
```

**Setup extlinux.conf**
```bash
#user@localhost:~$
sudo mkdir -p /mnt/rootfs/boot/extlinux/
sudo sh -c "echo 'label Linux ${kernel_version}' > /mnt/rootfs/boot/extlinux/extlinux.conf"
sudo sh -c "echo '    kernel /boot/vmlinuz-${kernel_version}' >> /mnt/rootfs/boot/extlinux/extlinux.conf"
sudo sh -c "echo '    append console=ttySTM0,115200 root=/dev/mmcblk0p4 ro rootfstype=ext4 rootwait quiet' >> /mnt/rootfs/boot/extlinux/extlinux.conf"
sudo sh -c "echo '    fdtdir /boot/dtbs/${kernel_version}/' >> /mnt/rootfs/boot/extlinux/extlinux.conf"
```

**Copy Kernel Image**
```bash
#user@localhost:~$
sudo cp -v ./armv7-lpae-multiplatform/deploy/${kernel_version}.zImage /mnt/rootfs/boot/vmlinuz-${kernel_version}
```

**Copy Kernel Device Tree Binaries**
```bash
#user@localhost:~$
sudo mkdir -p /mnt/rootfs/boot/dtbs/${kernel_version}/
sudo tar xfv ./armv7-lpae-multiplatform/deploy/${kernel_version}-dtbs.tar.gz -C /mnt/rootfs/boot/dtbs/${kernel_version}/
```

**Copy Kernel Modules**
```bash
#user@localhost:~$
sudo tar xfv ./armv7-lpae-multiplatform/deploy/${kernel_version}-modules.tar.gz -C /mnt/rootfs/
```

**File Systems Table (/etc/fstab)**
```bash
#user@localhost:~/$
sudo sh -c "echo '/dev/mmcblk0p4  /  auto  errors=remount-ro  0  1' >> /mnt/rootfs/etc/fstab"
```

**For DK2 board. WiFi bin and config files**
```bash
#user@localhost:~/$
wget -c https://raw.githubusercontent.com/STMicroelectronics/meta-st-stm32mp/dunfell/recipes-kernel/linux-firmware/linux-firmware/brcmfmac43430-sdio.txt 
wget -c https://github.com/murata-wireless/cyw-fmac-fw/raw/master/cyfmac43430-sdio.bin
wget -c https://github.com/murata-wireless/cyw-fmac-fw/raw/master/cyfmac43430-sdio.1DX.clm_blob
 
sudo mkdir -p /mnt/rootfs/lib/firmware/brcm/
 
sudo cp -v ./brcmfmac43430* /mnt/rootfs/lib/firmware/brcm/
sudo cp -v ./brcmfmac43430-sdio.txt /mnt/rootfs/lib/firmware/brcm/brcmfmac43430-sdio.st,stm32mp157c-dk2.txt
```

**Finish:**
```bash
sync
sudo umount /mnt/rootfs
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

