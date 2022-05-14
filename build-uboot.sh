#!/bin/bash

export LC_ALL=C
DIR=$PWD

UBOOT_VERSION="v2020.10"

. "${DIR}/.CC"
echo "CROSS_COMPILE=${CC}"

if [ ! "${CORES}" ] ; then
	CORES=$(($(getconf _NPROCESSORS_ONLN) * 2)) # cores and thread
fi


build_uboot(){
    echo "============================================"
    echo "Start get U-Boot"
    if [ -f ${DIR}/u-boot/u-boot.bin ]; then
        echo
       return 0
    fi 
    
    if ! [ -d ${DIR}/u-boot ]; then
		echo "============================================"
    	echo "Update submodule"
    	git submodule init
    	git submodule update
    fi
    
    cd ${DIR}/u-boot
    echo "============================================"
    echo "Start build U-Boot ${UBOOT_VERSION}"
    #git checkout ${UBOOT_VERSION}
    make ARCH=arm CROSS_COMPILE=${CC} distclean
	#make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig
    make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
	make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=stm32mp157c-dk2 all u-boot.stm32 -j${CORES}
	
	echo "============================================"
	if [ -f  u-boot.bin ]; then
	    echo "U-Boot Build Finish"
	
        mkdir -p "${DIR}/deploy/"

	    echo "Copy U-Boot to deploy folder"
	    #if [ -f ${DIR}/deploy/u-boot-spl.stm32 ]; then rm ${DIR}/deploy/u-boot-spl.stm32; fi
	    #if [ -f ${DIR}/deploy/u-boot.img ]; then rm ${DIR}/deploy/u-boot.img; fi
        #if [ -f ${DIR}/deploy/u-boot.bin ]; then rm ${DIR}/deploy/u-boot.bin; fi
	
	    #cp -v u-boot-spl.stm32 ${DIR}/deploy
	    cp -v u-boot.bin ${DIR}/deploy
	else
	    echo "U-Boot Build Failed"
        exit 1
	fi
	
	cd "${DIR}/" || exit 0
}


build_arm_trusted_firmware() {

    cd ${DIR}/arm-trusted-firmware
    echo "============================================"
    echo "Start build Arm Trusted Firmware "
   rm -r ./build
    make -C ./tools/fiptool \
        PLAT=stm32mp1 ARCH=aarch32 ARM_ARCH_MAJOR=7 CROSS_COMPILE=${CC} \
        STM32MP_SDMMC=1 STM32MP_EMMC=1 \
        AARCH32_SP=sp_min \
        DTB_FILE_NAME=stm32mp157c-dk2.dtb \
        BL33_CFG=${DIR}/u-boot/u-boot.dtb \
        BL33=${DIR}/u-boot/u-boot-nodtb.bin \
        -j${CORES}

    make  \
        PLAT=stm32mp1 ARCH=aarch32 ARM_ARCH_MAJOR=7 CROSS_COMPILE=${CC} \
        STM32MP_SDMMC=1 STM32MP_EMMC=1 \
        AARCH32_SP=sp_min \
        DTB_FILE_NAME=stm32mp157c-dk2.dtb \
        BL33_CFG=${DIR}/u-boot/u-boot.dtb \
        BL33=${DIR}/u-boot/u-boot-nodtb.bin \
        all fip -j${CORES}

	if [ -f ${DIR}/deploy/tf-a-stm32mp157c-dk2.stm32 ]; then 
            rm ${DIR}/deploy/tf-a-stm32mp157c-dk2.stm32
    fi

    cp -v ./build/stm32mp1/release/tf-a-stm32mp157c-dk2.stm32 ${DIR}/deploy

    if [ -f ${DIR}/deploy/fip.bin ]; then 
            rm ${DIR}/deploy/fip.bin
    fi
	
    cp -v ./build/stm32mp1/release/fip.bin ${DIR}/deploy
	   

    cd "${DIR}/" || exit 0

}

build_uboot

build_arm_trusted_firmware