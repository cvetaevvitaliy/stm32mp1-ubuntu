#!/bin/bash

DIR=$PWD
export LC_ALL=C

echo "*Helper script for build Ubuntu 22.04 for stm32mp1*"
/bin/sh -e "${DIR}/build-uboot.sh" || { exit 1 ; }
/bin/sh -e "${DIR}/build-linux.sh" || { exit 1 ; }
/bin/sh -e "${DIR}/rootfs.sh" || { exit 1 ; }
/bin/sh -e "${DIR}/create-rootfs.sh" || { exit 1 ; }