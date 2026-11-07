#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@mounting: mount the target partitions

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"
x::export_with_default 'X_INSTALL_EXECUTION' "dryrun"

install_esp_partition=$(x::install_esp_partition)
install_root_partition=$(x::install_root_partition)

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Mounting $install_root_partition..."

x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT"
x::install_exec mount "$install_root_partition" "$X_INSTALL_TARGET_ROOT"
x::install_exec chcon --reference=/ "$X_INSTALL_TARGET_ROOT"
if [ "$X_INSTALL_EXECUTION" != dryrun ] && ! mountpoint -q "$X_INSTALL_TARGET_ROOT"; then
    x::install_error mount_failed "Unable to mount $install_root_partition"
    exit 1
fi

if [ "$X_INSTALL_BOOT_TYPE" = "UEFI" ] && [ -n "$install_esp_partition" ]; then
    x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/boot/efi"
    x::install_exec mount -o uid=0,gid=0,fmask=0177,dmask=0077 "$install_esp_partition" "$X_INSTALL_TARGET_ROOT/boot/efi"
    x::install_exec chcon --reference=/boot/efi "$X_INSTALL_TARGET_ROOT/boot/efi"
    if [ "$X_INSTALL_EXECUTION" != dryrun ]; then
        mountpoint -q "$X_INSTALL_TARGET_ROOT/boot/efi" || {
            x::install_error mount_failed "Unable to mount $install_esp_partition"
            exit 1
        }
        # Re-verify the mounted ESP can hold the bootloader files
        esp_size=$(lsblk -bdnlo SIZE "$install_esp_partition" 2>/dev/null)
        if [[ "$esp_size" =~ ^[0-9]+$ ]] && [ "$esp_size" -lt 67108864 ]; then
            x::install_error esp_too_small "The mounted EFI System Partition is too small"
            exit 1
        fi
    fi
fi

# API filesystems so that chroot-based steps (kernel-install, dracut,
# grub2-mkconfig) work on the target like on a booted system
x::install_exec mount --bind /dev "$X_INSTALL_TARGET_ROOT/dev"
x::install_exec mount -t devpts devpts "$X_INSTALL_TARGET_ROOT/dev/pts"
x::install_exec mount -t tmpfs tmpfs "$X_INSTALL_TARGET_ROOT/dev/shm"
x::install_exec mount -t proc proc "$X_INSTALL_TARGET_ROOT/proc"
x::install_exec mount -t sysfs sysfs "$X_INSTALL_TARGET_ROOT/sys"
[ -d /sys/fs/selinux ] && \
    x::install_exec mount -t selinuxfs selinuxfs "$X_INSTALL_TARGET_ROOT/sys/fs/selinux"
x::install_exec mount --bind /run "$X_INSTALL_TARGET_ROOT/run"
if [ "$X_INSTALL_BOOT_TYPE" = "UEFI" ]; then
    x::install_exec mount -t efivarfs efivarfs "$X_INSTALL_TARGET_ROOT/sys/firmware/efi/efivars"
fi
x::install_exec mount -t tmpfs tmpfs "$X_INSTALL_TARGET_ROOT/tmp"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Target mounted on $X_INSTALL_TARGET_ROOT."
