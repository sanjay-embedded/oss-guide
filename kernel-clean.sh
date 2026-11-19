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
echo ${BUILD_OUT}
mkdir ${BUILD_OUT}

# clean kernel and it's artifacts
make O=${BUILD_OUT} mrproper
git clean -xdf

