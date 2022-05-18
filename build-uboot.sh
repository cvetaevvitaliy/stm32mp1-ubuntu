#!/bin/bash

export LC_ALL=C
DIR=$PWD

/bin/sh -e "${DIR}/gcc.sh" || { exit 1 ; }

. "${DIR}/.CC"
. "${DIR}/version.sh"
echo "CROSS_COMPILE=${CC}"

if [ ! "${CORES}" ] ; then
	CORES=$(($(getconf _NPROCESSORS_ONLN) * 2)) # cores and thread
fi

mkdir -p "${DIR}/deploy/"

build_uboot() {    
    cd ${DIR}/u-boot

    echo "Apply patch"
    git apply -v --whitespace=fix ${DIR}/00004-add-u-boot-stm32mp157a-sodimm2-mx.patch || { echo "Error apply patch"; }

    echo "============================================"
    echo "Start build U-Boot: $(git branch --show-current)"
    echo "Board: ${board}"

    make ARCH=arm CROSS_COMPILE=${CC} distclean
	#make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_basic_defconfig # non trusted u-boot
    make ARCH=arm CROSS_COMPILE=${CC} stm32mp15_trusted_defconfig
	make ARCH=arm CROSS_COMPILE=${CC} DEVICE_TREE=${board} all u-boot.stm32 -j${CORES}
	
	echo "============================================"
	if [ -f  u-boot.bin ]; then
	    echo "U-Boot Build Finish"
	
        mkdir -p "${DIR}/deploy"

	    echo "Copy U-Boot to deploy folder"
       # non trusted u-boot
	    #if [ -f ${DIR}/deploy/u-boot-spl.stm32 ]; then rm ${DIR}/deploy/u-boot-spl.stm32; fi
	    #if [ -f ${DIR}/deploy/u-boot.img ]; then rm ${DIR}/deploy/u-boot.img; fi
        #if [ -f ${DIR}/deploy/u-boot.bin ]; then rm ${DIR}/deploy/u-boot.bin; fi
	    #cp -v u-boot-spl.stm32 ${DIR}/deploy

	    cp -v u-boot.bin ${DIR}/deploy
	else
        export ERROR_MSG="U-Boot: Build Failure: board ${board}"
		/bin/sh -e "${DIR}/error.sh" && { exit 1 ; }
	fi
	
	cd "${DIR}/" || exit 0
}


build_arm_trusted_firmware() {

    cd ${DIR}/arm-trusted-firmware
    echo "Apply patch"
    git apply -v --whitespace=fix ${DIR}/00005-add-at-f-stm32mp157a-sodimm2-mx.patch || { echo "Error apply patch"; }
    echo "============================================"
    echo "Start build Arm Trust Firmware: ${board} $(git branch --show-current)"
    
    if [ -d ${DIR}/arm-trusted-firmware/build ]; then 
           rm -r ${DIR}/arm-trusted-firmware/build
    fi

    make -C ./tools/fiptool \
        PLAT=stm32mp1 ARCH=aarch32 ARM_ARCH_MAJOR=7 CROSS_COMPILE=${CC} \
        STM32MP_SDMMC=1 STM32MP_EMMC=1 \
        AARCH32_SP=sp_min \
        DTB_FILE_NAME=${board}.dtb \
        BL33_CFG=${DIR}/u-boot/u-boot.dtb \
        BL33=${DIR}/u-boot/u-boot-nodtb.bin \
        -j${CORES}

    make  \
        PLAT=stm32mp1 ARCH=aarch32 ARM_ARCH_MAJOR=7 CROSS_COMPILE=${CC} \
        STM32MP_SDMMC=1 STM32MP_EMMC=1 \
        AARCH32_SP=sp_min \
        DTB_FILE_NAME=${board}.dtb \
        BL33_CFG=${DIR}/u-boot/u-boot.dtb \
        BL33=${DIR}/u-boot/u-boot-nodtb.bin \
        all fip -j${CORES}

    
    echo "============================================"
	if [ -f  ./build/stm32mp1/release/fip.bin ]; then
	    echo "Arm Trust Firmware Build Finish"
    else
        export ERROR_MSG="Arm Trust Firmware: Build Failure: board ${board}: $(git branch --show-current)"
		/bin/sh -e "${DIR}/error.sh" && { exit 1 ; }
	fi    

	if [ -f ${DIR}/deploy/tf-a-${board}.stm32 ]; then 
            rm ${DIR}/deploy/tf-a-${board}.stm32
    fi

    cp -v ./build/stm32mp1/release/tf-a-${board}.stm32 ${DIR}/deploy

    if [ -f ${DIR}/deploy/fip.bin ]; then 
            rm ${DIR}/deploy/fip.bin
    fi
	
    cp -v ./build/stm32mp1/release/fip.bin ${DIR}/deploy
	   

    cd "${DIR}/" || exit 0

}

OPTIONS="${@:-allff}"

for option in ${OPTIONS}; do
    # echo "processing option: $option"
    case $option in
    stm32mp157a-sodimm2-mx) board=${OPTIONS} ;;
    stm32mp157c-dk2) board={OPTIONS} ;;

    *) board="stm32mp157c-dk2" ;;
    esac
done


build_uboot

build_arm_trusted_firmware

echo ""
echo "-----------------------------"
echo "Script Complete: board name: ${board}"
echo ""
echo "Trusted U-boot:   ${DIR}/deploy/fib.bin"
echo "Config RAM:       ${DIR}/deploy/tf-a-${board}.stm32"
echo "-----------------------------"

exit 0 ; 