#!/bin/bash


export LC_ALL=C
DIR=$PWD

. "${DIR}/version.sh"

IMAGE_FILENAME="sdcard-stm32mp157.img"
MOUNT_PATH="${DIR}/deploy/rootfs_tmp"


init_image(){

    if ! [ -f ${DIR}/deploy/${IMAGE_FILENAME} ]; then
        echo "Create ${IMAGE_FILENAME}"
        dd if=/dev/zero of=${DIR}/deploy/${IMAGE_FILENAME} bs=4096M count=2 || { exit 1 ; }
    
        echo "Create file systems ${IMAGE_FILENAME}"
        sgdisk --resize-table=128 -a 1 \
            -n 1:34:545    -c 1:fsbl1   \
            -n 2:546:1057  -c 2:fsbl2   \
            -n 3:1058:5153 -c 3:fip    \
            -n 4:5154:     -c 4:rootfs  \
            -p ${DIR}/deploy/${IMAGE_FILENAME}
    
        echo ""
        echo "Set legacy BIOS partition:"
           sgdisk -A 4:set:2 ${DIR}/deploy/${IMAGE_FILENAME} || { exit 1 ; }
           
    else
        echo "Found image ${IMAGE_FILENAME}"
        echo ""
    fi
    
    if ! [ -f ${DIR}/deploy/${IMAGE_FILENAME} ]; then
        echo "Error create ${IMAGE_FILENAME}"
        echo ""
        exit 1 ;
    fi

}

create_loop() {

    echo "Create loop device, need root access for use losetup"
    LOOP_DEVICE=$(sudo losetup --partscan --show --find ./deploy/${IMAGE_FILENAME})
    echo "Create loop device '${LOOP_DEVICE}'"
    
    echo "Print info about loop"
    ls -l ${LOOP_DEVICE}*
    echo ""

}

clean_loop() {

    echo "Try umount folder: '${MOUNT_PATH}'"
    sudo umount ${MOUNT_PATH}
    case "$?" in 
    	0) echo "umount '${MOUNT_PATH}' OK"  ;;
    	*) echo "Error mmount folder '${MOUNT_PATH}'" ;;
    esac

    echo "Clean up loop: '${LOOP_DEVICE}' "
    sudo losetup -D
    case "$?" in 
    	0) echo "Clean loop '${LOOP_DEVICE}' device OK"  ;;
    	*) echo "Error clean '${LOOP_DEVICE}' device " ;;
    esac
    echo "Finish"
}

write_uboot() {
    echo "============================================"
    echo "Install U-Boot bootloader version ${UBOOT_VERSION}:"
    if [ -f ${DIR}/deploy/fip.bin ]; then
    #if [ -f ${DIR}/deploy/u-boot.img ]; then
        # sudo dd if=${DIR}/deploy/u-boot-spl.stm32 of=${LOOP_DEVICE}0p1
        # sudo dd if=${DIR}/deploy/u-boot-spl.stm32 of=${LOOP_DEVICE}p2
        # sudo dd if=${DIR}/deploy/u-boot.img of=${LOOP_DEVICE}p3
        sudo dd if=${DIR}/deploy/tf-a-${board}.stm32 of=${LOOP_DEVICE}p1
        sudo dd if=${DIR}/deploy/tf-a-${board}.stm32 of=${LOOP_DEVICE}p2
        sudo dd if=${DIR}/deploy/fip.bin of=${LOOP_DEVICE}p3
    else
        echo "Error, Uboot not found"
        clean_loop
        exit 1
    fi

}

write_rootfs(){

    echo "Format RootFS Partition:"
    echo ""
    sudo mkfs.ext4 -L rootfs ${LOOP_DEVICE}p4

    echo "Mount rootfs file system to ${MOUNT_PATH}"
    echo ""
    sudo mkdir -p ${MOUNT_PATH}
    sudo mount ${LOOP_DEVICE}p4 ${MOUNT_PATH}

    if [ -d ${DIR}/deploy ]; then
        kernel_ver=$(cat "${DIR}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )
        echo "Kernel version ${kernel_ver}"
    else
        echo "First need build Kernel, please make './build.sh kernel'"
        clean_loop
        exit 1
    fi



    echo ""
    echo "Extract and copy Root File System: ${DIR}/dl/${rootfs_name}"
    if [ -f "${DIR}/dl/${rootfs_name}" ]; then
        # ubuntu-base-22.04-base-armhf.tar.gz
        # sudo tar xvfp ./deploy/${UBUNTU_18_VERSION}/*/*.tar -C ${MOUNT_PATH}
        # sudo tar xvfp ${DIR}/ubuntu-base-22.04-base-armhf.tar.gz -C ${MOUNT_PATH}
        #sudo tar xzpf ${DIR}/deploy/rootfs.tar.gz -C ${MOUNT_PATH}
        sudo tar xzpf ${DIR}/dl/${rootfs_name} -C ${MOUNT_PATH} || { clean_loop ; exit 1 ; }
        #sudo cp -ar ${DIR}/deploy/rootfs/.  ${MOUNT_PATH}
        #sudo rsync -azvh ${DIR}/rootfs/.  ${MOUNT_PATH}
        # sudo tar xfp ${DIR}/dl/${rootfs_name} -C ${MOUNT_PATH}
    else
        echo "First need get rootfs"
        clean_loop
        exit 1
    fi

}

copy_kernel_and_modules(){
    #fbcon=rotate:3
    unset boot_instance

    echo ""
    echo "Setup extlinux.conf"
    sudo mkdir -p ${MOUNT_PATH}/boot/extlinux/
    sudo sh -c "echo 'label Linux ${kernel_ver}' > ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    sudo sh -c "echo '    kernel /boot/vmlinuz-${kernel_ver}' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    sudo sh -c "echo '    append console=ttySTM0,115200 console=tty1,115200 root=/dev/mmcblk\${boot_instance}p4 ro rootwait ' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"
    sudo sh -c "echo '    fdtdir /boot/dtbs/${kernel_ver}/' >> ${MOUNT_PATH}/boot/extlinux/extlinux.conf"


    echo ""
    echo "Copy Kernel Image"
    sudo cp -v ./deploy/${kernel_ver}.zImage ${MOUNT_PATH}/boot/vmlinuz-${kernel_ver}

    echo ""
    echo "Copy Kernel Device Tree Binaries"
    sudo mkdir -p ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/
    sudo tar xfv ./deploy/${kernel_ver}-dtbs.tar.gz -C ${MOUNT_PATH}/boot/dtbs/${kernel_ver}/

    echo ""
    echo "Copy Kernel Modules"
    sudo tar xf ./deploy/${kernel_ver}-modules.tar.gz -C ${MOUNT_PATH}/usr/

    # echo ""
    # echo "Copy GPU video driver" # sudo depmod -a
    # echo "first start, need rescan all modules: 'sudo depmod -a'"
    # sudo mkdir -p ${MOUNT_PATH}/lib/modules/${kernel_ver}/extra/
    # sudo cp -v ${DIR}/gcnano-driver-6.4.3/galcore.ko ${MOUNT_PATH}/lib/modules/${kernel_ver}/extra/

    sudo sh -c "echo 'allow-hotplug eth0' >> ${MOUNT_PATH}/etc/network/interfaces"
    sudo sh -c "echo 'iface eth0 inet dhcp' >> ${MOUNT_PATH}/etc/network/interfaces"

    echo ""
    echo "Copy WiFi firmware"
    sudo mkdir -p ${MOUNT_PATH}/lib/firmware/brcm/
    sudo cp -v ./wifi_firmware/* ${MOUNT_PATH}/lib/firmware/brcm/
    sudo cp -v ./wifi_firmware/brcmfmac43430-sdio.txt ${MOUNT_PATH}/lib/firmware/brcm/brcmfmac43430-sdio.st,${board}.txt
    

    # add wellcome information
    sudo sh -c "echo 'Ubuntu 22.04 LTS \\l' > ${MOUNT_PATH}/etc/issue"
    sudo sh -c "echo 'Build: $(date +'%d/%m/%Y')' >> ${MOUNT_PATH}/etc/issue"
    sudo sh -c "echo ' ' >> ${MOUNT_PATH}/etc/issue"
    sudo sh -c "echo 'login: ubuntu' >> ${MOUNT_PATH}/etc/issue"
    sudo sh -c "echo 'passw: root' >> ${MOUNT_PATH}/etc/issue"
    sudo sh -c "echo ' ' >> ${MOUNT_PATH}/etc/issue"
# activate welcome message
    # sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/00-header
    # sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/10-help-text
    # sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/50-motd-news
    # sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/80-esm
    # sudo chmod +x ${MOUNT_PATH}/etc/update-motd.d/80-livepatch

    echo ""
    echo "Copy helper scripts"
    sudo cp -v ./script/resize_sd.sh ${MOUNT_PATH}/usr/bin/
    sudo cp -v ./script/activate_wifi.sh ${MOUNT_PATH}/usr/bin/
    
    echo ""
    echo "File Systems Table (/etc/fstab)"
    sudo sh -c "echo '/dev/mmcblk0p4  /  auto  errors=remount-ro  0  1' >> ${MOUNT_PATH}/etc/fstab"

    ls -l ${MOUNT_PATH}/
    ls -l ${MOUNT_PATH}/home/
    
    sync
    case "$?" in
    0) echo "Sync OK"  ;;
    *) echo "Error sync " ;;
    esac

    mkdir -p ${DIR}/artifacts

    if [ -f "${DIR}/artifacts/$(date +'%d-%m-%Y')-Ubuntu-22.04-base-${board}.img" ]; then
        rm ${DIR}/artifacts/$(date +'%d-%m-%Y')-Ubuntu-22.04-base-${board}.img
    fi
    
    mv -v ${DIR}/deploy/${IMAGE_FILENAME} ${DIR}/artifacts/$(date +'%d-%m-%Y')-Ubuntu-22.04-base-${board}.img

}

OPTIONS="${@:-allff}"

for option in ${OPTIONS}; do
    # echo "processing option: $option"
    case $option in
    stm32mp157a-sodimm2-mx) board=${OPTIONS} ;;
    stm32mp157c-dk2) board=${OPTIONS} ;;
    stm32mp157a-avenger96) board=${OPTIONS} ;;
    stm32mp157a-ev1) board=${OPTIONS} ;;
    stm32mp157a-iot-box) board=${OPTIONS} ;;
    stm32mp157a-stinger96) board=${OPTIONS} ;;
    stm32mp157c-dhcom-pdk2) board=${OPTIONS} ;;
    stm32mp157c-ed1) board=${OPTIONS} ;;
    stm32mp157c-ev1) board=${OPTIONS} ;;
    stm32mp157c-lxa-mc1) board=${OPTIONS} ;;
    stm32mp157c-odyssey) board=${OPTIONS} ;;
    stm32mp157d-dk1) board=${OPTIONS} ;;
    stm32mp157d-ed1) board=${OPTIONS} ;;
    stm32mp157d-ev1) board=${OPTIONS} ;;
    stm32mp157f-dk2) board=${OPTIONS} ;;
    stm32mp157f-ed1) board=${OPTIONS} ;;
    stm32mp157f-ev1) board=${OPTIONS} ;;
    stm32mp157a-dk1) board=${OPTIONS} ;;
    stm32mp157a-ed1) board=${OPTIONS} ;;

    *) board="stm32mp157c-dk2" ;;
    esac
done



init_image

create_loop

write_uboot

write_rootfs

copy_kernel_and_modules

clean_loop

