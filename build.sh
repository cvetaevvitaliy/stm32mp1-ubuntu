#!/bin/bash

export LC_ALL=C

# TODO: need to make config file for configure build versions
UBOOT_VERSION="v2021.10"
KERNEL_VERSION="5.15.6-armv7-lpae-x11"
ROOTFS_NAME="custom_image"
ROOT_FS_LINK="https://rcn-ee.com/rootfs/eewiki/minfs/${ROOTFS_NAME}"
UBUNTU_VERSION="ubuntu"

UBUNTU_18="ubuntu-18.04.6-minimal-armhf-2021-11-02.tar.xz"
UBUNTU_20="ubuntu-20.04.3-minimal-armhf-2021-11-02.tar.xz"
DEBIAN_10="debian-10.11-minimal-armhf-2021-11-02.tar.xz"
DEBIAN_11="debian-11.1-minimal-armhf-2021-11-02.tar.xz"

DOWNLOAD_LINK="https://rcn-ee.com/rootfs/eewiki/minfs/"

CUR_PATH=$(pwd)

IMAGE_FILENAME=sdcard-stm32mp157.img
MOUNT_PATH="./output/rootfs"


function usage()
{
	echo "Usage: build.sh [OPTIONS]"
    echo "Available options:"
    echo "all                -build uboot, kernel, rootfs, recovery image"
    echo "uboot              -build uboot"
    echo "kernel             -build kernel"
    echo "modules            -copy kernel modules"
    echo "toolchain          -download toolchain"
    echo "debian             -build debian stretch rootfs"
    echo "ubuntu             -build ubuntu stretch rootfs"
    echo "mkimage            -create sdcard.img file"
    echo "cleanall           -clean uboot, kernel, rootfs"
    echo "check              -check the environment of building"
    echo "info               -see the current  building information"
    echo "qemu               -Mount image and usage QEMU Full-system emulation"
    echo ""
}

function check_download_dir(){
	if ! [ -d ./download_dir ]; then
	mkdir download_dir
	fi
}

function check_output_dir(){
	if ! [ -d ./output ]; then
	mkdir output
	fi
}


function build_all(){
    echo "============================================"
    echo "Start build All"
    build_uboot
}


function build_uboot(){
    echo "============================================"
    echo "Start get U-Boot"
    get_toolchain
    check_output_dir
    
    if ! [ -d ./u-boot ]; then
		echo "============================================"
    	echo "Update submodule"
    	git submodule init
    	git submodule update
    fi
    
    cd u-boot
    echo "============================================"
    echo "Start build U-Boot ${UBOOT_VERSION}"
    git checkout ${UBOOT_VERSION} -b ${UBOOT_VERSION}
    make ARCH=arm CROSS_COMPILE=${CC} distclean
	make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig
	make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-dk2 all -j8
	
	echo "============================================"
	if [ -f u-boot.img ]; then
	echo "U-Boot Build Finish"
	
	echo "Copy file to output folder ${CUR_PATH}/output"
	if [ -f ../output/u-boot-spl.stm32 ]; then rm ../output/u-boot-spl.stm32; fi
	if [ -f ../output/u-boot.img ]; then rm ../output/u-boot.img; fi
	
	cp u-boot-spl.stm32 ../output
	cp u-boot.img ../output
	else
	echo "U-Boot Build Failed"
	fi
	
	cd ..
}


function build_kernel(){
    BUILD_KERNEL="./build_kernel.sh"
    	
    if ! [ -d ./armv7-lpae-multiplatform ]; then
		echo "============================================"
    	echo "Init submodule Kernel source"
    	git submodule init
    	git submodule update
    fi
    
    echo "============================================"
    echo "Start build Kernel"
    cd armv7-lpae-multiplatform
    
    echo "Get Kernel version '${KERNEL_VERSION}'"
    git reet --hard
    git checkout ${KERNEL_VERSION}
    echo "Start build Kernel ${KERNEL_VERSION}"
    (exec "$BUILD_KERNEL")
    cd ..
    
}

function build_modules(){
    	echo "============================================"
    	echo "Start copy kernel modules"
}


function get_toolchain(){
	if ! [ -d ./toolchain ]; then
    	echo "============================================"
    	echo "toolchain dir not foun"
	mkdir toolchain
	fi
	
	if ! [ -d ./toolchain/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf ]; then
	
		if ! [ -n "$(command -v wget)" ]; then
		echo "WGET not found"
		apt get install wget-y
		fi
	
		if ! [ -f ./download_dir/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz ]; then
		check_download_dir
		wget -P ./download_dir https://releases.linaro.org/components/toolchain/binaries/6.5-2018.12/arm-linux-gnueabihf/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz
		tar xvf ./download_dir/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf.tar.xz -C ./toolchain
		fi
	
	fi

	export CC=`pwd`/toolchain/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
	echo "============================================"
	echo "Toolchain path: '${CC}'"
	echo $(${CC}gcc --version)
	echo "============================================"


}


function download_debian(){
    echo "============================================"
    echo "Start download Debian"
}

function download_ubuntu(){
    echo "============================================"
    echo "Download ${UBUNTU_VERSION} "
    check_download_dir
    
    if ! [ -f ./download_dir/${ROOTFS_NAME} ]; then
    wget -P ./download_dir ${ROOT_FS_LINK}
    fi
    
    if ! [ -d ./${UBUNTU_VERSION} ]; then
    mkdir ./${UBUNTU_VERSION}
    echo "Extract to ${CUR_PATH}/${UBUNTU_VERSION} "
    tar xvf ./download_dir/${ROOTFS_NAME} -C ./${UBUNTU_VERSION}
    fi
}


function check(){
	    case "$?" in 
    	0) echo "OK"  ;;
    	*) echo "Error" 
    	calenup ;;
    	esac
}


function calenup(){
    echo ""
    echo "Try umount folder: '${MOUNT_PATH}'"
    sudo umount ${MOUNT_PATH}
    case "$?" in 
    	0) echo "umount '${MOUNT_PATH}' OK"  ;;
    	*) echo "Error mmount folder '${MOUNT_PATH}'" ;;
    esac

    echo "Try clean up loop: '${LOOP_DEVICE}' "
    sudo losetup -D
    case "$?" in 
    	0) echo "Clean loop '${LOOP_DEVICE}' device OK"  ;;
    	*) echo "Error clean '${LOOP_DEVICE}' device " ;;
    esac
    echo "Finish"
    #exit 0
}


function init_image(){

    if ! [ -f ./output/${IMAGE_FILENAME} ]; then
        echo "Create ${IMAGE_FILENAME}"
        dd if=/dev/zero of=./output/${IMAGE_FILENAME} bs=4096M count=2
        check
    
        echo "Create file systems ${IMAGE_FILENAME}"
        sgdisk --resize-table=128 -a 1 \
            -n 1:34:545    -c 1:fsbl1   \
            -n 2:546:1057  -c 2:fsbl2   \
            -n 3:1058:5153 -c 3:ssbl    \
            -n 4:5154:     -c 4:rootfs  \
            -p ./output/${IMAGE_FILENAME}
        check
    
        echo ""
        echo "Set legacy BIOS partition:"
           sgdisk -A 4:set:2 ./output/${IMAGE_FILENAME}
           check
    else
        echo "Found image ${IMAGE_FILENAME}"
        echo ""
    fi
    
    if ! [ -f ./output/${IMAGE_FILENAME} ]; then
        echo "Error create ${IMAGE_FILENAME}"
        echo ""
        exit;
    fi

}

function create_loop(){

    echo "Create loop device, need root access for use losetup"
    LOOP_DEVICE=$(sudo losetup --partscan --show --find ./output/${IMAGE_FILENAME})
    echo "Create loop device '${LOOP_DEVICE}'"
    
    echo "Print info about loop"
    ls -l ${LOOP_DEVICE}*
    echo ""

}

function format_rootfs(){

    echo "Format RootFS Partition:"
    echo ""
    sudo mkfs.ext4 -L rootfs ${LOOP_DEVICE}p4
    check
}

function install_uboot(){
    echo "============================================"
    echo "Install U-Boot bootloader version ${UBOOT_VERSION}:"
    if [ -f ./output/u-boot.img ]; then
        sudo dd if=./output/u-boot-spl.stm32 of=${LOOP_DEVICE}0p1
        sudo dd if=./output/u-boot-spl.stm32 of=${LOOP_DEVICE}p2
        sudo dd if=./output/u-boot.img of=${LOOP_DEVICE}p3
    else
        echo "First need build U-Boot, please make './build.sh uboot'"
    exit 0
    fi

}

function copy_kernel(){

    echo "Mount rootfs file system to ${MOUNT_PATH}"
    echo ""
    sudo mkdir -p ${MOUNT_PATH}
    sudo mount ${LOOP_DEVICE}p4 ${MOUNT_PATH}
    check

    echo ""
    if [ -d ./armv7-lpae-multiplatform/deploy ]; then
    kernel_ver=$(basename ./armv7-lpae-multiplatform/deploy/*.zImage | rev | cut -c 8- | rev )
    echo "Kernel version ${kernel_ver}"
    else
    echo "First need build Kernel, please make './build.sh kernel'"
    exit 0
    fi

}


function copy_all_configs_and_modules(){
    echo ""
    echo "Setup extlinux.conf"
    sudo mkdir -p ${MOUNT_PATH}/boot/extlinux/
    sudo sh -c "echo 'label Linux ${kernel_ver}' > ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    sudo sh -c "echo '    kernel /boot/vmlinuz-${kernel_ver}' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    sudo sh -c "echo '    append console=ttySTM0,115200 console=tty1,115200 fbcon=rotate:3 root=/dev/mmcblk0p4 ro rootfstype=ext4 rootwait' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    sudo sh -c "echo '    fdtdir /boot/dtbs/${kernel_ver}/' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    check

    echo ""
    echo "Copy Kernel Image"
    sudo cp -v ./armv7-lpae-multiplatform/deploy/${kernel_ver}.zImage ${MOUNT_PATH}/boot/vmlinuz-${kernel_ver}
    check


    echo ""
    echo "Copy Kernel Device Tree Binaries"
    sudo mkdir -p ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
    sudo tar xf ./armv7-lpae-multiplatform/deploy/${kernel_ver}-dtbs.tar.gz -C ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
    check

    echo ""
    echo "Copy Kernel Modules"
    sudo tar xfv ./armv7-lpae-multiplatform/deploy/${kernel_ver}-modules.tar.gz -C ${MOUNT_PATH}
    check

    sudo sh -c "echo 'auto eth0' >> ${MOUNT_PATH}/etc/network/interfaces"
    sudo sh -c "echo 'iface eth0 inet dhcp' >> ${MOUNT_PATH}/etc/network/interfaces"

    echo ""
    echo "Copy WiFi firmware"
    sudo mkdir -p ${MOUNT_PATH}/lib/firmware/brcm/
    sudo cp -v ./wifi_firmware/brcmfmac43430* ${MOUNT_PATH}/lib/firmware/brcm/
    sudo cp -v ./wifi_firmware/brcmfmac43430-sdio.txt ${MOUNT_PATH}/lib/firmware/brcm/brcmfmac43430-sdio.st,stm32mp157c-dk2.txt
    check

# activate welcome message
    sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/00-header
    sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/10-help-text
    sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/50-motd-news
    sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/80-esm
    sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/80-livepatch

    echo ""
    echo "Copy helper scripts"
    sudo cp -v ./script/resize_sd.sh ${MOUNT_PATH}/usr/bin/
    sudo cp -v ./script/activate_wifi.sh ${MOUNT_PATH}/usr/bin/
    
    echo ""
    echo "File Systems Table (/etc/fstab)"
    sudo sh -c "echo '/dev/mmcblk0p4  /  auto  errors=remount-ro  0  1' >> ${MOUNT_PATH}/etc/fstab"
    check
    
    sync
    case "$?" in
    0) echo "Sync OK"  ;;
    *) echo "Error sync " ;;
    esac
}


function create_image(){
    echo "============================================"
    echo "Start create image"
    echo ""
    
    check_output_dir
    init_image
    create_loop
    install_uboot
    format_rootfs
    copy_kernel
    
    
#    echo "Format RootFS Partition:"
#    echo ""
#    sudo mkfs.ext4 -L rootfs ${LOOP_DEVICE}p4
#    check

#    MOUNT_PATH="./output/rootfs"
#
#    echo "Mount rootfs file system to ${MOUNT_PATH}"
#    echo ""
#    sudo mkdir -p ${MOUNT_PATH}
#    sudo mount ${LOOP_DEVICE}p4 ${MOUNT_PATH}
#    check
#
#    echo ""
#    if [ -d ./armv7-lpae-multiplatform/deploy ]; then
#	kernel_ver=$(basename ./armv7-lpae-multiplatform/deploy/*.zImage | rev | cut -c 8- | rev )
#	echo "Kernel version ${kernel_ver}"
#    else
#	echo "First need build Kernel, please make './build.sh kernel'"
#	exit 0
#    fi


    echo ""
    echo "Copy Root File System"
    if [ -d ./${UBUNTU_VERSION} ]; then
	echo "Extract to ${CUR_PATH}/${UBUNTU_VERSION} "
	sudo tar xfp ./${UBUNTU_VERSION}/*/*.tar -C ${MOUNT_PATH}
	check
    else
	echo "First need get rootfs, please make './build.sh ubuntu'"
	exit 0
    fi


    echo ""
    echo "Setup extlinux.conf"
	sudo mkdir -p ${MOUNT_PATH}/boot/extlinux/
	sudo sh -c "echo 'label Linux ${kernel_ver}' > ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
	sudo sh -c "echo '    kernel /boot/vmlinuz-${kernel_ver}' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
	sudo sh -c "echo '    append console=ttySTM0,115200 console=tty1,115200 fbcon=rotate:3 root=/dev/mmcblk0p4 ro rootfstype=ext4 rootwait' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
	sudo sh -c "echo '    fdtdir /boot/dtbs/${kernel_ver}/' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
	check

    echo ""
    echo "Copy Kernel Image"
	sudo cp -v ./armv7-lpae-multiplatform/deploy/${kernel_ver}.zImage ${MOUNT_PATH}/boot/vmlinuz-${kernel_ver}
	check


    echo ""
    echo "Copy Kernel Device Tree Binaries"
	sudo mkdir -p ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
	sudo tar xf ./armv7-lpae-multiplatform/deploy/${kernel_ver}-dtbs.tar.gz -C ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
	check

    echo ""
    echo "Copy Kernel Modules"
	sudo tar xfv ./armv7-lpae-multiplatform/deploy/${kernel_ver}-modules.tar.gz -C ${MOUNT_PATH}
	check

	sudo sh -c "echo 'auto eth0' >> ${MOUNT_PATH}/etc/network/interfaces"
	sudo sh -c "echo 'iface eth0 inet dhcp' >> ${MOUNT_PATH}/etc/network/interfaces"

    echo ""
    echo "Copy WiFi firmware"
	sudo mkdir -p ${MOUNT_PATH}/lib/firmware/brcm/
	sudo cp -v ./wifi_firmware/brcmfmac43430* ${MOUNT_PATH}/lib/firmware/brcm/
	sudo cp -v ./wifi_firmware/brcmfmac43430-sdio.txt ${MOUNT_PATH}/lib/firmware/brcm/brcmfmac43430-sdio.st,stm32mp157c-dk2.txt
	check

# activate welcome message
	sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/00-header
	sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/10-help-text
	sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/50-motd-news
	sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/80-esm
	sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/80-livepatch

    echo ""
    echo "Copy helper scripts"
	sudo cp -v ./script/resize_sd.sh ${MOUNT_PATH}/usr/bin/
	sudo cp -v ./script/activate_wifi.sh ${MOUNT_PATH}/usr/bin/
	
    echo ""
    echo "File Systems Table (/etc/fstab)"
	sudo sh -c "echo '/dev/mmcblk0p4  /  auto  errors=remount-ro  0  1' >> ${MOUNT_PATH}/etc/fstab"
	check
    
	sync
	case "$?" in 
	0) echo "Sync OK"  ;;
	*) echo "Error sync " ;;
	esac

	calenup
    
}


function open_qemu(){
    echo ""
    echo "Open QENU emulator"

    echo "Create loop device, need root access for use losetup"
    LOOP_DEVICE=$(sudo losetup --partscan --show --find ./output/${IMAGE_FILENAME})
    echo "Create loop device '${LOOP_DEVICE}'"
    
    echo "Print info about loop"
    ls -l ${LOOP_DEVICE}*
    echo ""

    echo "Mount rootfs file system to ${MOUNT_PATH}"
    echo ""
    sudo mkdir -p ${MOUNT_PATH}
    sudo mount ${LOOP_DEVICE}p4 ${MOUNT_PATH}
    check
    
    
    sudo cp /usr/bin/qemu-arm-static  ${MOUNT_PATH}/usr/bin/
    #sudo rm ${MOUNT_PATH}/etc/resolv.conf
    #sudo touch ${MOUNT_PATH}/etc/resolv.conf
    #sudo sh -c echo "nameserver 8.8.8.8" > ${MOUNT_PATH}/etc/resolv.conf
    (exec ./ch-mount.sh -m ${MOUNT_PATH} )
    echo "Clean up"
    (exec ./ch-mount.sh -u ${MOUNT_PATH} )

    sync
    calenup


}

function build_cleanall(){
    echo "============================================"
    echo "Start clean all"
}


function check_env(){
    echo "============================================"
    echo "Start check environment"
}


function build_info(){
    echo "============================================"
    echo "Build information"
}

function mk_ubuntu_18(){
    echo "============================================"
    echo "Create Ubuntu 18 image"
    
    if ! [ -f ./download_dir/${UBUNTU_18} ]; then
        wget -P ./download_dir ${DOWNLOAD_LINK}${UBUNTU_18}
    fi
    
    UBUNTU_18_VERSION="ubuntu_18_rootfs"
    if ! [ -d ./${UBUNTU_18_VERSION} ]; then
        mkdir ./${UBUNTU_18_VERSION}
        echo "Extract to ${CUR_PATH}/${UBUNTU_18_VERSION} "
        tar xvf ./download_dir/${UBUNTU_18} -C ./${UBUNTU_18_VERSION}
    fi
    
    check_output_dir
    init_image
    create_loop
    install_uboot
    format_rootfs
    copy_kernel
    
    echo ""
    echo "Copy Root File System"
    if [ -d ./${UBUNTU_18_VERSION} ]; then
        echo "Extract to ${CUR_PATH}/${UBUNTU_18_VERSION} "
        sudo tar xvfp ./${UBUNTU_18_VERSION}/*/*.tar -C ${MOUNT_PATH}
        check
    else
        echo "First need get rootfs, please make './build.sh ubuntu'"
        exit 0
    fi
    
    copy_all_configs_and_modules
    
    
    calenup
    
    echo "Compress SD card image"
    TAR_NAME=$(basename ${UBUNTU_18} | cut -c 1-14)
    echo "${TAR_NAME}"
    # tar cfv - ./output/sdcard-stm32mp157.img | pv | xz -z -T0 - > ./output/${TAR_NAME}-full-sd-image.tar.xz
    pv ./output/sdcard-stm32mp157.img | gzip  > ./output/${TAR_NAME}-kernel-${KERNEL_VERSION}-full-sd-image.img.gz
    echo "Image stored: /output/${TAR_NAME}-kernel-${KERNEL_VERSION}-full-sd-image.img.gz"
    
}

function mk_ubuntu_20(){
    echo "============================================"
    echo "Create Ubuntu 20 image"
    
    if ! [ -f ./download_dir/${UBUNTU_20} ]; then
        echo "Download file"
        wget -P ./download_dir ${DOWNLOAD_LINK}${UBUNTU_20}
    fi
    
    UBUNTU_20_VERSION="ubuntu_20_rootfs"
    if ! [ -d ./${UBUNTU_20_VERSION} ]; then
        mkdir ./${UBUNTU_20_VERSION}
        echo "Extract to ${CUR_PATH}/${UBUNTU_20_VERSION} "
        tar xvf ./download_dir/${UBUNTU_20} -C ./${UBUNTU_20_VERSION}
    fi
    
    check_output_dir
    init_image
    create_loop
    install_uboot
    format_rootfs
    copy_kernel
    
    echo ""
    echo "Copy Root File System"
    if [ -d ./${UBUNTU_18_VERSION} ]; then
        echo "Extract to ${CUR_PATH}/${UBUNTU_20_VERSION} "
        sudo tar xvfp ./${UBUNTU_20_VERSION}/*/*.tar -C ${MOUNT_PATH}
        check
    else
        echo "First need get rootfs, please make './build.sh ubuntu'"
        exit 0
    fi
    
    copy_all_configs_and_modules
    
    
    calenup
    
    echo "Compress SD card image"
    TAR_NAME=$(basename ${UBUNTU_20} | cut -c 1-14)
    echo "${TAR_NAME}"
    # tar cfv - ./output/sdcard-stm32mp157.img | pv | xz -z -T0 - > ./output/${TAR_NAME}-full-sd-image.tar.xz
    pv ./output/sdcard-stm32mp157.img | gzip  > ./output/${TAR_NAME}-kernel-${KERNEL_VERSION}-full-sd-image.img.gz
    
    
}


function debian_11(){

    echo "============================================"
    echo "Create Debian 11 image"
    
    if ! [ -f ./download_dir/${DEBIAN_11} ]; then
        echo "Download file"
        wget -P ./download_dir ${DOWNLOAD_LINK}${DEBIAN_11}
    fi
    
    DEBIAN_VERSION="debian_11_rootfs"
    if ! [ -d ./${DEBIAN_VERSION} ]; then
        mkdir ./${DEBIAN_VERSION}
        echo "Extract to ${CUR_PATH}/${DEBIAN_VERSION} "
        tar xvf ./download_dir/${DEBIAN_11} -C ./${DEBIAN_VERSION}
    fi
    
    check_output_dir
    init_image
    create_loop
    install_uboot
    format_rootfs
    copy_kernel
    
    echo ""
    echo "Copy Root File System"
    if [ -d ./${DEBIAN_VERSION} ]; then
        echo "Extract to ${CUR_PATH}/${DEBIAN_VERSION} "
        sudo tar xvfp ./${DEBIAN_VERSION}/*/*.tar -C ${MOUNT_PATH}
        check
    else
        echo "First need get rootfs, please make './build.sh ubuntu'"
        exit 0
    fi
    
    copy_all_configs_and_modules
    
    
    calenup
    
    echo "Compress SD card image"
    TAR_NAME=$(basename ${DEBIAN_11} | cut -c 1-11)
    echo "${TAR_NAME}"
    # tar cfv - ./output/sdcard-stm32mp157.img | pv | xz -z -T0 - > ./output/${TAR_NAME}-full-sd-image.tar.xz
    pv ./output/sdcard-stm32mp157.img | gzip  > ./output/${TAR_NAME}-kernel-${KERNEL_VERSION}-full-sd-image.img.gz

}

function debian_10(){

    echo "============================================"
    echo "Create Debian 10 image"
    
    if ! [ -f ./download_dir/${DEBIAN_10} ]; then
        echo "Download file"
        wget -P ./download_dir ${DOWNLOAD_LINK}${DEBIAN_10}
    fi
    
    DEBIAN_VERSION_10="debian_10_rootfs"
    if ! [ -d ./${DEBIAN_VERSION_10} ]; then
        mkdir ./${DEBIAN_VERSION_10}
        echo "Extract to ${CUR_PATH}/${DEBIAN_VERSION_10} "
        tar xvf ./download_dir/${DEBIAN_10} -C ./${DEBIAN_VERSION_10}
    fi
    
    check_output_dir
    init_image
    create_loop
    install_uboot
    format_rootfs
    copy_kernel
    
    echo ""
    echo "Copy Root File System"
    if [ -d ./${DEBIAN_10_VERSION} ]; then
        echo "Extract to ${CUR_PATH}/${DEBIAN_VERSION_10} "
        sudo tar xvfp ./${DEBIAN_VERSION_10}/*/*.tar -C ${MOUNT_PATH}
        check
    else
        echo "First need get rootfs, please make './build.sh ubuntu'"
        exit 0
    fi
    
    copy_all_configs_and_modules
    
    
    calenup
    
    echo "Compress SD card image"
    TAR_NAME=$(basename ${DEBIAN_10} | cut -c 1-11)
    echo "${TAR_NAME}"
    # tar cfv - ./output/sdcard-stm32mp157.img | pv | xz -z -T0 - > ./output/${TAR_NAME}-full-sd-image.tar.xz
    pv ./output/sdcard-stm32mp157.img | gzip  > ./output/${TAR_NAME}-kernel-${KERNEL_VERSION}-full-sd-image.img.gz

}


function compress_img(){
    echo "Compress SD card image"
    TAR_NAME=${ROOTFS_NAME}
    echo "${TAR_NAME}"
    # tar cfv - ./output/sdcard-stm32mp157.img | pv | xz -z -T0 - > ./output/${TAR_NAME}-full-sd-image.tar.xz
    pv ./output/sdcard-stm32mp157.img | gzip  > ./output/${TAR_NAME}-${KERNEL_VERSION}-full-sd-image.img.gz
}



if echo $@|grep -wqE "help|-h"; then
    if [ -n "$2" -a "$(type -t usage$2)" == function ]; then
	echo "###Current Default [ $2 ] Build Command###"
	eval usage$2
    else
	usage
    fi
    exit 0
fi


OPTIONS="${@:-allff}"


for option in ${OPTIONS}; do
    # echo "processing option: $option"
    case $option in
    all) build_all ;;
    uboot) build_uboot ;;
    kernel) build_kernel ;;
    modules) build_modules ;;
    toolchain) get_toolchain ;;
    debian) download_debian ;;
    ubuntu) download_ubuntu ;;
    mkimage) create_image ;;
    qemu) open_qemu ;;
    cleanall) build_cleanall ;;
    check) check_env ;;
    compress_img) compress_img ;;
    info) build_info ;;
    mkubuntu18) mk_ubuntu_18 ;;
    mkubuntu20) mk_ubuntu_20 ;;
    mkdebian11) debian_11 ;;
    mkdebian10) debian_10 ;;
    *) usage ;;
    esac
done

