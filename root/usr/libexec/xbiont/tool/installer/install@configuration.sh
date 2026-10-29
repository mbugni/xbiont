#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@configuration: configure the target system

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"

install_esp_partition=$(x::install_esp_partition)
install_root_partition=$(x::install_root_partition)

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Generating fstab..."

# Update /etc/fstab to reflect the new partition layout
x::export_with_default 'X_INSTALL_FS_TYPE' "xfs"
x::install_exec sh -c "echo UUID=\$(blkid -s UUID -o value $install_root_partition) / $X_INSTALL_FS_TYPE defaults 0 0 >> $X_INSTALL_TARGET_ROOT/etc/fstab"
x::install_exec sh -c "echo UUID=\$(blkid -s UUID -o value $install_esp_partition) /boot/efi vfat umask=0077,shortname=winnt 0 2 >> $X_INSTALL_TARGET_ROOT/etc/fstab"

x::install_progress $(( (X_INSTALL_PERCENTAGE_MIN + X_INSTALL_PERCENTAGE_MAX) / 2 )) \
    "Copying regional settings..."

# Copy the regional settings from the running live system (Phase 1),
# not from the squashfs image: locale, keyboard, timezone
x::install_exec cp /etc/locale.conf "$X_INSTALL_TARGET_ROOT/etc/locale.conf"
x::install_exec cp /etc/vconsole.conf "$X_INSTALL_TARGET_ROOT/etc/vconsole.conf"
x::install_exec cp -a /etc/localtime "$X_INSTALL_TARGET_ROOT/etc/localtime"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Target system configured."
