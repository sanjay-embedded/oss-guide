#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2025 Sanjay Chitroda <sanjayembeddedse@gmail.com>
#
# This tool provide x86 ubuntu linux build commands
#

echo "Parent Termianl ID: $PPID"
echo "Current Terminal ID: $$"

BUILD_DIR=build-`git branch --show-current`

# Define build output directory
BUILD_OUT=${PWD}/${BUILD_DIR}
echo $BUILD_OUT
mkdir ${BUILD_OUT}

# Copy and prepare config (in build dir)
cp /boot/config-$(uname -r) ${BUILD_OUT}/.config

# Disable kernel signature keys
scripts/config --file ${BUILD_OUT}/.config --disable SYSTEM_TRUSTED_KEYS
scripts/config --file ${BUILD_OUT}/.config --disable SYSTEM_REVOCATION_KEYS

# Resolve dependent config symbols AFTER modifying .config
make O=${BUILD_OUT} olddefconfig

# Build the kernel
make O=${BUILD_OUT} -j$(nproc)

# Install modules and kernel
sudo make O=${BUILD_OUT} modules_install install

