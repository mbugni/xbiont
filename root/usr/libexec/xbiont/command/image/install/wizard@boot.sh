#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@boot: run the image installer boot configuration

X_INSTALL_BOOT_TYPE="UEFI"
[ ! -d "/sys/firmware/efi" ] && X_INSTALL_BOOT_TYPE="LEGACY"

X_INSTALL_BOOT_TYPE=$(dialog --stdout \
    --title " Boot Configuration " \
    --radiolist "\nSelect the boot mode for the target system:" 15 75 5 \
    "UEFI"   "Install UEFI (Recommended for modern systems)" $( [ "$X_INSTALL_BOOT_TYPE" == "UEFI" ] && echo "ON" || echo "OFF" ) \
    "LEGACY" "Install Legacy MBR (Required for older systems)" $( [ "$X_INSTALL_BOOT_TYPE" == "LEGACY" ] && echo "ON" || echo "OFF" ) \
    "NONE"   "No Bootloader (Managed externally)" OFF \
    </dev/tty)
x::install_check_cancel

echo "$X_INSTALL_BOOT_TYPE"
