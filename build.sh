#!/bin/bash
#Script to build buildroot configuration
#Author: Siddhant Jajoo

source shared.sh
export HOSTCC=$(command -v gcc-13 || command -v gcc)
export HOSTCXX=$(command -v g++-13 || command -v g++)
#export BR2_DL_DIR=${HOME}/.dl


EXTERNAL_REL_BUILDROOT=../base_external
git submodule init
git submodule sync
git submodule update

set -e 
cd `dirname $0`

if [ ! -e buildroot/.config ]
then
	echo "MISSING BUILDROOT CONFIGURATION FILE"

	if [ -e ${AESD_MODIFIED_DEFCONFIG} ]
	then
		echo "USING ${AESD_MODIFIED_DEFCONFIG}"
		# Allow chmod failures during extraction (bind-mount restriction)
		sed -i 's/$(Q)chmod -R +rw $(@D)/$(Q)chmod -R +rw $(@D) || true/' buildroot/package/pkg-generic.mk
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT} -j 16
	else
		echo "Run ./save_config.sh to save this as the default configuration in ${AESD_MODIFIED_DEFCONFIG}"
		echo "Then add packages as needed to complete the installation, re-running ./save_config.sh as needed"
		# Allow chmod failures during extraction (bind-mount restriction)
		sed -i 's/$(Q)chmod -R +rw $(@D)/$(Q)chmod -R +rw $(@D) || true/' buildroot/package/pkg-generic.mk
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${AESD_DEFAULT_DEFCONFIG} -j 16
	fi
else
	echo "USING EXISTING BUILDROOT CONFIG"
	sed -i 's/$(Q)chmod -R +rw $(@D)/$(Q)chmod -R +rw $(@D) || true/' buildroot/package/pkg-generic.mk
	echo "To force update, delete .config or make changes using make menuconfig and build again."
	make -C buildroot BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} -j 16

fi
