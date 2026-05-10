#!/bin/bash
#Script to build buildroot configuration
#Author: Siddhant Jajoo
source shared.sh
export HOSTCC=$(command -v gcc-13 || command -v gcc)
export HOSTCXX=$(command -v g++-13 || command -v g++)
export BR2_DL_DIR=${HOME}/.dl
export BR2_TAR_OPTIONS="--no-same-owner --no-same-permissions"
EXTERNAL_REL_BUILDROOT=../base_external
OUTPUT_DIR=/tmp/buildroot-output

git submodule init
git submodule sync
git submodule update
set -e
cd `dirname $0`

mkdir -p ${OUTPUT_DIR}

if [ ! -e ${OUTPUT_DIR}/.config ]
then
    echo "MISSING BUILDROOT CONFIGURATION FILE"
    if [ -e ${AESD_MODIFIED_DEFCONFIG} ]
    then
        echo "USING ${AESD_MODIFIED_DEFCONFIG}"
        make -C buildroot O=${OUTPUT_DIR} defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT}
    else
        echo "USING ${AESD_DEFAULT_DEFCONFIG}"
        make -C buildroot O=${OUTPUT_DIR} defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_DEFAULT_DEFCONFIG}
    fi
else
    echo "USING EXISTING BUILDROOT CONFIG"
    echo "To force update, delete .config or make changes using make menuconfig and build again."
fi

make -C buildroot O=${OUTPUT_DIR} BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} -j$(nproc)
