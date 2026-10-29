#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@mounting: mount the target partitions

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"

install_esp_partition=$(x::install_esp_partition)
install_root_partition=$(x::install_root_partition)

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Mounting $install_root_partition..."

x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT"
x::install_exec mount "$install_root_partition" "$X_INSTALL_TARGET_ROOT"

if [ "$X_INSTALL_BOOT_TYPE" != "NONE" ] && [ -n "$install_esp_partition" ]; then
    x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/boot/efi"
    x::install_exec mount "$install_esp_partition" "$X_INSTALL_TARGET_ROOT/boot/efi"
fi

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Target mounted on $X_INSTALL_TARGET_ROOT."
