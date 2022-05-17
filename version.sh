#!/bin/sh
#
ARCH=$(uname -m)

#board ?= "stm32mp157a-sodimm2-mx"
#board="stm32mp157c-dk2"

config="multi_v7_defconfig"

# base rootfs
link_ubuntu_relese="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release"
base_rootfs_name="ubuntu-base-22.04-base-armhf.tar.gz"

# Googledrive link to rootfs
fileid="1kEco22WrjYhaFoAfxaGbd41blzu6kYSC"
rootfs_name="ubuntu-22.04-base-stm32mp1-armhf-16-05-2022.tar.gz"


#arm
KERNEL_ARCH=arm
DEBARCH=armhf
#toolchain="gcc_6_arm"
#toolchain="gcc_7_arm"
#toolchain="gcc_8_arm"
#toolchain="gcc_9_arm"
toolchain="gcc_10_arm"
#toolchain="gcc_11_arm"

#
