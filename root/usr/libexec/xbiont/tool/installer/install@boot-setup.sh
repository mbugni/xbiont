#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@boot-setup: setup the bootloader on the target system

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"

install_target_disk=$(x::install_target_disk)

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Setting up the bootloader..."

case "$X_INSTALL_BOOT_TYPE" in
UEFI)
    # GRUB2 UEFI with BLS entries, like the Anaconda installer does on Fedora
    x::install_exec grub2-install \
        --target=x86_64-efi \
        --efi-directory="$X_INSTALL_TARGET_ROOT/boot/efi" \
        --bootloader-id="$X_DISTRO_ID" \
        --recheck
    # Regenerate BLS entries in /boot/loader/entries and the GRUB2 config
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" kernel-install add-all
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" grub2-mkconfig -o /boot/grub2/grub.cfg
    # Register the bootloader in the UEFI boot menu
    x::install_exec efibootmgr --create \
        --disk "$install_target_disk" --part 1 \
        --label "$X_DISTRO_ID" \
        --loader "\\EFI\\$(echo "$X_DISTRO_ID" | tr '[:lower:]' '[:upper:]')\\shimx64.efi"
    ;;
MBR)
    x::install_exec grub2-install --target=i386-pc "$install_target_disk"
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" grub2-mkconfig -o /boot/grub2/grub.cfg
    ;;
NONE)
    x::install_progress $X_INSTALL_PERCENTAGE_MAX "Bootloader installation skipped (managed externally)."
    ;;
esac

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Bootloader setup completed."
