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
x::export_with_default 'X_INSTALL_EXECUTION' "dryrun"

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Copying the live system to the target..."

# Mount the squashfs image containing the original root filesystem;
# the source is always unmounted on exit, even on failure
x::install_exec mkdir -p "$X_INSTALL_LIVE_SOURCE"
if [ "$X_INSTALL_EXECUTION" != dryrun ]; then
    trap 'umount -l "$X_INSTALL_LIVE_SOURCE" 2>/dev/null || true' EXIT
fi
x::install_exec sync
x::install_exec mount -o ro "$X_INSTALL_LIVE_IMAGE" "$X_INSTALL_LIVE_SOURCE"

# -x stays on the live filesystem, and --no-inc-recursive computes the
# transfer total up front so progress reporting is meaningful.
# Excludes: API filesystems, machine identity, bootloader content that is
# rewritten by the boot-setup step, and paths that fail on KIWI-built
# images (security.selinux xattrs) which are re-copied below without them.
rsync_excludes=(
    --exclude='/dev/' --exclude='/proc/' --exclude='/sys/' --exclude='/run/' --exclude='/tmp/*'
    --exclude='/boot/*rescue*' --exclude='/boot/loader/' --exclude='/boot/efi/'
    --exclude='/etc/machine-id' --exclude='/etc/machine-info'
    --exclude='/boot/grub2/' --exclude='/etc/sysconfig/' --exclude='/usr/lib/grub/'
)
rsync_args=(-pogAXtlHrDx --stats --info=flist2,name,progress2 --no-inc-recursive)

if [ "$X_INSTALL_EXECUTION" = dryrun ]; then
    x::install_exec rsync "${rsync_args[@]}" "${rsync_excludes[@]}" \
        "$X_INSTALL_LIVE_SOURCE/" "$X_INSTALL_TARGET_ROOT/"
else
    # Parse the progress2 percentage into scaled progress events
    rsync_log=$(mktemp)
    rsync "${rsync_args[@]}" "${rsync_excludes[@]}" \
        "$X_INSTALL_LIVE_SOURCE/" "$X_INSTALL_TARGET_ROOT/" 2>"$rsync_log" \
        | tr '\r' '\n' | while read -r line; do
            percent=$(sed -n 's/.*[[:space:]]\([0-9]\{1,3\}\)%.*/\1/p' <<< "$line")
            [ -n "$percent" ] || continue
            scaled=$(( X_INSTALL_PERCENTAGE_MIN + percent * (X_INSTALL_PERCENTAGE_MAX - X_INSTALL_PERCENTAGE_MIN) * 80 / 100 / 100 ))
            x::install_progress "$scaled" "Copying the live system to the target ($percent%)..."
        done
    rsync_status=${PIPESTATUS[0]}
    grep 'rsync:' "$rsync_log" >&2 || true
    if [ "$rsync_status" -eq 23 ] && grep -q '\[sender\]' "$rsync_log"; then
        rm -f "$rsync_log"
        x::install_error corrupted_media "The installation media appears to be corrupted"
        exit 1
    elif [ "$rsync_status" -ne 0 ]; then
        rm -f "$rsync_log"
        x::install_error copy_failed "Copying the live system failed (rsync exited with $rsync_status)"
        exit 1
    fi
    rm -f "$rsync_log"
fi

# KIWI fixup: re-copy the excluded paths without xattrs/ACLs
for fixup_dir in boot/grub2 etc/sysconfig usr/lib/grub; do
    x::install_exec rsync -rx "$X_INSTALL_LIVE_SOURCE/$fixup_dir/" "$X_INSTALL_TARGET_ROOT/$fixup_dir/"
done

# ESP contents in a separate pass: FAT has no owners, xattrs or links
if [ "$X_INSTALL_BOOT_TYPE" = "UEFI" ] && [ -n "$(x::install_esp_partition)" ]; then
    x::install_exec rsync -rx --exclude='loader/' \
        "$X_INSTALL_LIVE_SOURCE/boot/efi/" "$X_INSTALL_TARGET_ROOT/boot/efi/"
fi

x::install_exec umount -l "$X_INSTALL_LIVE_SOURCE"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Live system copied to the target."
