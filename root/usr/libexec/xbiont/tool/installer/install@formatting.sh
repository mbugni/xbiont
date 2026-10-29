#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@formatting: format the target partitions

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"

# Predefined filesystems: ext4 for Debian, xfs for Fedora/CentOS
case "$X_DISTRO_ID" in
debian|ubuntu) X_INSTALL_FS_TYPE="ext4" ;;
*) X_INSTALL_FS_TYPE="xfs" ;;
esac

install_esp_partition=$(x::install_esp_partition)
install_root_partition=$(x::install_root_partition)

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Formatting $install_root_partition as $X_INSTALL_FS_TYPE..."

if [ "$(x::install_target_type)" == "disk" ]; then
    # ESP was just created: format it as FAT32
    x::install_exec mkfs.vfat -F32 -n EFI "$install_esp_partition"
fi

# The root partition is always formatted, regardless of the selection type
x::install_exec "mkfs.$X_INSTALL_FS_TYPE" -f -L root "$install_root_partition"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Formatting completed."
