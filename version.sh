#!/bin/sh
#
ARCH=$(uname -m)

#board ?= "stm32mp157a-sodimm2-mx"
#board="stm32mp157c-dk2"

config="multi_v7_defconfig"


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
