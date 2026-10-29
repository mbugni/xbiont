#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@copying: copy the live system to the target system

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"
x::export_with_default 'X_INSTALL_LIVE_SOURCE' "/run/install-source"
x::export_with_default 'X_INSTALL_LIVE_IMAGE' "/dev/mapper/live-base"

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Copying the live system to the target..."

# Mount the squashfs image containing the original root filesystem
x::install_exec mkdir -p "$X_INSTALL_LIVE_SOURCE"
x::install_exec mount -o ro "$X_INSTALL_LIVE_IMAGE" "$X_INSTALL_LIVE_SOURCE"

x::install_exec rsync -aAXH --info=progress2 \
    "$X_INSTALL_LIVE_SOURCE/" "$X_INSTALL_TARGET_ROOT/"

x::install_exec umount "$X_INSTALL_LIVE_SOURCE"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Live system copied to the target."
