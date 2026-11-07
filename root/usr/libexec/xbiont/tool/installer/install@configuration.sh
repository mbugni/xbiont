#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@configuration: configure the target system

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"
x::export_with_default 'X_INSTALL_FS_TYPE' "xfs"
x::export_with_default 'X_INSTALL_ROOT_UUID' "UNKNOWN"
x::export_with_default 'X_INSTALL_ESP_UUID' "UNKNOWN"

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Generating fstab..."

# Rewrite /etc/fstab deterministically from the captured layout
install_fstab="# /etc/fstab — written by the xbiont installer
UUID=$X_INSTALL_ROOT_UUID / $X_INSTALL_FS_TYPE defaults 0 0"
if [ "$X_INSTALL_BOOT_TYPE" = "UEFI" ] && [ -n "$(x::install_esp_partition)" ]; then
    install_fstab="$install_fstab
UUID=$X_INSTALL_ESP_UUID /boot/efi vfat uid=0,gid=0,fmask=0177,dmask=0077 0 2"
fi
x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/etc"
x::install_write_file "$X_INSTALL_TARGET_ROOT/etc/fstab" <<< "$install_fstab"

x::install_progress $(( (X_INSTALL_PERCENTAGE_MIN + X_INSTALL_PERCENTAGE_MAX) / 2 )) \
    "Copying regional settings..."

# Copy the regional settings from the running live system (Phase 1),
# not from the squashfs image: locale, keyboard, timezone
[ -f /etc/locale.conf ] && \
    x::install_exec cp /etc/locale.conf "$X_INSTALL_TARGET_ROOT/etc/locale.conf"
[ -f /etc/vconsole.conf ] && \
    x::install_exec cp /etc/vconsole.conf "$X_INSTALL_TARGET_ROOT/etc/vconsole.conf"
[ -e /etc/localtime ] && \
    x::install_exec cp -a /etc/localtime "$X_INSTALL_TARGET_ROOT/etc/localtime"
[ -f /etc/timezone ] && \
    x::install_exec cp /etc/timezone "$X_INSTALL_TARGET_ROOT/etc/timezone"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Target system configured."
