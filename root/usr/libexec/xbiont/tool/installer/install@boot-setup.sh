#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@boot-setup: setup the bootloader on the target system

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"
x::export_with_default 'X_INSTALL_ROOT_UUID' "UNKNOWN"
x::export_with_default 'X_INSTALL_EXECUTION' "dryrun"

install_target_disk=$(x::install_target_disk)
install_esp_partition=$(x::install_esp_partition)

# Kernels to set up: from the copied target, falling back to the mounted
# live image (which is what the dry-run preview enumerates)
install_kernels=$(x::install_kernel_versions "$X_INSTALL_TARGET_ROOT")
[ -n "$install_kernels" ] || install_kernels="<kernel-version>"

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Setting up the bootloader..."

case "$X_INSTALL_BOOT_TYPE" in
UEFI)
    # A fresh machine-id is required before kernel-install and
    # grub2-mkconfig, which embed it into the BLS entry names
    x::install_exec rm -f "$X_INSTALL_TARGET_ROOT/etc/machine-id"
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" systemd-machine-id-setup
    x::install_exec rm -f "$X_INSTALL_TARGET_ROOT/var/lib/dbus/machine-id"
    x::install_exec ln -s /etc/machine-id "$X_INSTALL_TARGET_ROOT/var/lib/dbus/machine-id"
    install_machine_id=$(cat "$X_INSTALL_TARGET_ROOT/etc/machine-id" 2>/dev/null || echo "UNKNOWN")

    # Boot configuration for the target layout: kernel command line,
    # GRUB2 defaults with BLS entries, default kernel metadata
    x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/etc/kernel" "$X_INSTALL_TARGET_ROOT/etc/default" "$X_INSTALL_TARGET_ROOT/etc/sysconfig"
    x::install_write_file "$X_INSTALL_TARGET_ROOT/etc/kernel/cmdline" <<< "root=UUID=$X_INSTALL_ROOT_UUID ro"
    x::install_write_file "$X_INSTALL_TARGET_ROOT/etc/default/grub" <<< "\
GRUB_ENABLE_BLSCFG=true
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_CMDLINE_LINUX=\"root=UUID=$X_INSTALL_ROOT_UUID ro\""
    x::install_write_file "$X_INSTALL_TARGET_ROOT/etc/sysconfig/kernel" <<< "\
UPDATEDEFAULT=yes
DEFAULTKERNEL=kernel-core"

    # BLS entries copied from the image carry the wrong machine-id:
    # remove them and let kernel-install recreate them per kernel
    x::install_exec rm -f "$X_INSTALL_TARGET_ROOT"/boot/loader/entries/*.conf
    for kernel_version in $install_kernels; do
        x::install_exec chroot "$X_INSTALL_TARGET_ROOT" kernel-install add "$kernel_version" "/lib/modules/$kernel_version/vmlinuz"
    done

    # The signed shim/GRUB binaries come from the copied image — there is
    # no grub2-install on EFI. The ESP gets a stub config that locates the
    # root filesystem by UUID and loads the real grub.cfg from it
    x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/boot/efi/EFI/$X_DISTRO_ID"
    x::install_write_file "$X_INSTALL_TARGET_ROOT/boot/efi/EFI/$X_DISTRO_ID/grub.cfg" <<< "\
search --no-floppy --fs-uuid --set=dev $X_INSTALL_ROOT_UUID
set prefix=(\$dev)/grub2
export \$prefix
configfile \$prefix/grub.cfg"

    # Register the bootloader: drop stale NVRAM entries with the same
    # label first, then create a new one on the real ESP partition
    if [ "$(x::install_target_type)" == "disk" ]; then
        esp_partnum=1
    else
        esp_partnum=$(x::install_partition_number "$install_esp_partition")
    fi
    esp_disk=$(lsblk -dnpo PKNAME "$install_esp_partition" 2>/dev/null | head -n1 || true)
    [ -n "$esp_disk" ] || esp_disk="$install_target_disk"
    if [ "$X_INSTALL_EXECUTION" = dryrun ]; then
        x::install_exec efibootmgr -b 0000 -B
        x::install_log "dryrun: remove any existing '$X_DISTRO_ID' boot entries"
    else
        while read -r bootnum; do
            x::install_exec efibootmgr -b "$bootnum" -B
        done < <(efibootmgr 2>/dev/null | sed -n "s/^Boot\([0-9A-Fa-f]\{4\}\)\* *$X_DISTRO_ID.*/\1/p")
    fi
    x::install_exec efibootmgr -c -w -L "$X_DISTRO_ID" \
        -d "$esp_disk" -p "$esp_partnum" \
        -l "\\EFI\\$X_DISTRO_ID\\shimx64.efi"

    # Default boot entry and final GRUB2 config
    default_kernel=$(head -n1 <<< "$install_kernels")
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" grub2-editenv - create
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" grub2-set-default "$install_machine_id-$default_kernel"
    x::install_exec chroot "$X_INSTALL_TARGET_ROOT" grub2-mkconfig -o /boot/grub2/grub.cfg

    # Regenerate the initramfs now that all configuration is in place:
    # the live one is a generic dmsquash-live image
    for kernel_version in $install_kernels; do
        x::install_exec chroot "$X_INSTALL_TARGET_ROOT" depmod -a "$kernel_version"
        x::install_exec chroot "$X_INSTALL_TARGET_ROOT" dracut -f "/boot/initramfs-$kernel_version.img" "$kernel_version"
    done
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
