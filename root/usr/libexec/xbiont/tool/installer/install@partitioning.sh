#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@partitioning: create the partition layout on the target device

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"

install_target_disk=$(x::install_target_disk)

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Partitioning $install_target_disk..."

# Clean up leftovers from previous runs before touching the disk:
# unmount anything still mounted under the target root (best effort)
set +e
while read -r stale_mount; do
    x::install_exec umount "$stale_mount"
done < <(findmnt -rn -o TARGET -R "$X_INSTALL_TARGET_ROOT" 2>/dev/null | sort -r)
set -e

x::install_exec partprobe -s "$install_target_disk"

if [ "$(x::install_target_type)" == "disk" ]; then
    # Whole disk selected: fresh GPT with ESP (256M) + root partition
    x::install_exec sgdisk --zap-all "$install_target_disk"
    x::install_exec wipefs -a -f "$install_target_disk"
    x::install_exec sgdisk -n1:1MiB:+256MiB -t1:EF00 -c1:ESP "$install_target_disk"
    x::install_exec sgdisk -n2:0:0 -t2:8300 -c2:root "$install_target_disk"
else
    # Existing partition selected: reuse the ESP already present on the disk
    x::install_progress $(( (X_INSTALL_PERCENTAGE_MIN + X_INSTALL_PERCENTAGE_MAX) / 2 )) \
        "Reusing existing layout on $install_target_disk..."
fi

x::install_exec partprobe -s "$install_target_disk"
x::install_exec udevadm settle

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Partitioning completed."
