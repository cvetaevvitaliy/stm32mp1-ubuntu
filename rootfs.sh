#!/bin/bash

DIR=$PWD
. "${DIR}/version.sh"

if [ -d ${DIR}/dl ] ; then
	mkdir -p "${DIR}/dl"
fi

if [ -d ${DIR}/dl ] ; then
	mkdir -p "${DIR}/dl"
fi


if [ -f "${DIR}/dl/${base_rootfs_name}" ] ; then
    echo "File downloaded: ${DIR}/dl/${base_rootfs_name}"
    #exit 0 ;
else 
    wget -P "${DIR}/dl" "${link_ubuntu_relese}/${base_rootfs_name}" || { exit 1 ; }
fi


# https://drive.google.com/file/d/1kEco22WrjYhaFoAfxaGbd41blzu6kYSC/view?usp=sharing
fileid="1kEco22WrjYhaFoAfxaGbd41blzu6kYSC"
rootfs_name="ubuntu-22.04-base-stm32mp1-armhf-16-05-2022.tar.gz"

URL="https://docs.google.com/uc?export=download&id=${fileid}"
cd "${DIR}/dl"
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate $URL -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=${fileid}" -O ${rootfs_name} && rm -rf /tmp/cookies.txt  || { cd "${DIR}" ; exit 1 ; }
cd "${DIR}"
exit 0 ;